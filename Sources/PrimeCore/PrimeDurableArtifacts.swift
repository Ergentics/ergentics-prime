#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import CryptoKit
import CoreFoundation
import Foundation

public enum PrimeDurableArtifactError: Error, Equatable, Sendable {
    case invalidRelativePath(String)
    case untrustedDirectory(String)
    case nonemptyArtifactRoot
    case unsafeArtifact(String)
    case conflictingArtifact(String)
    case artifactTooLarge(String)
    case hashMismatch(
        path: String,
        expected: String,
        actual: String
    )
    case byteCountMismatch(
        path: String,
        expected: UInt64,
        actual: UInt64
    )
    case nonCanonicalJSON(String)
    case invalidObservation(String)
    case invalidSemantics(String)
    case posix(
        operation: String,
        path: String,
        code: Int32
    )
    case unsupportedPlatform(String)
}

extension PrimeDurableArtifactError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidRelativePath(path):
            return "invalid descriptor-relative artifact path: \(path)"
        case let .untrustedDirectory(path):
            return "artifact directory is not trusted: \(path)"
        case .nonemptyArtifactRoot:
            return "artifact root must be empty before a new run"
        case let .unsafeArtifact(path):
            return "artifact is not a safe, single-link regular file: \(path)"
        case let .conflictingArtifact(path):
            return "an immutable artifact already exists with different bytes: \(path)"
        case let .artifactTooLarge(path):
            return "artifact exceeds the declared read limit: \(path)"
        case let .hashMismatch(path, expected, actual):
            return "artifact hash mismatch for \(path): expected \(expected), got \(actual)"
        case let .byteCountMismatch(path, expected, actual):
            return "artifact byte count mismatch for \(path): expected \(expected), got \(actual)"
        case let .nonCanonicalJSON(path):
            return "artifact is not canonical JSON: \(path)"
        case let .invalidObservation(detail):
            return "invalid typed observation: \(detail)"
        case let .invalidSemantics(detail):
            return "invalid Prime receipt semantics: \(detail)"
        case let .posix(operation, path, code):
            return "\(operation) failed for \(path): \(String(cString: strerror(code)))"
        case let .unsupportedPlatform(detail):
            return detail
        }
    }
}

public enum PrimeCanonicalJSON {
    public static func encode<Value: Encodable>(
        _ value: Value
    ) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        return try encoder.encode(value)
    }

    public static func decode<Value: Codable>(
        _ type: Value.Type,
        from data: Data,
        artifact: String = "<memory>"
    ) throws -> Value {
        let value = try JSONDecoder().decode(type, from: data)
        guard try encode(value) == data else {
            throw PrimeDurableArtifactError.nonCanonicalJSON(
                artifact
            )
        }
        return value
    }
}

public enum PrimeSHA256 {
    private static let hexadecimal = Array(
        "0123456789abcdef".utf8
    )

    public static func hexDigest(of data: Data) -> String {
        encode(SHA256.hash(data: data))
    }

    fileprivate static func encode<Digest: Sequence>(
        _ digest: Digest
    ) -> String where Digest.Element == UInt8 {
        var bytes = [UInt8]()
        bytes.reserveCapacity(64)
        for byte in digest {
            bytes.append(hexadecimal[Int(byte >> 4)])
            bytes.append(hexadecimal[Int(byte & 0x0f)])
        }
        return String(decoding: bytes, as: UTF8.self)
    }
}

public enum PrimeArtifactPurpose: String, Codable, Sendable {
    case immutableData = "immutable_data"
    case executable

    fileprivate var mode: mode_t {
        switch self {
        case .immutableData:
            return mode_t(0o444)
        case .executable:
            return mode_t(0o555)
        }
    }
}

public struct PrimeArtifactBinding:
    Codable,
    Equatable,
    Sendable
{
    public let relativePath: String
    public let sha256: String
    public let byteCount: UInt64
    public let purpose: PrimeArtifactPurpose

    public init(
        relativePath: String,
        sha256: String,
        byteCount: UInt64,
        purpose: PrimeArtifactPurpose
    ) {
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
        self.purpose = purpose
    }

    func validateDeclaration() throws {
        _ = try PrimeArtifactRoot.components(
            of: relativePath
        )
        guard sha256.utf8.count == 64,
              sha256.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                      || ($0 >= 97 && $0 <= 102)
              }) else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "SHA-256 must be 64 lowercase hexadecimal characters"
            )
        }
    }
}

public struct PrimeVerifiedArtifact:
    Equatable,
    Sendable
{
    public let binding: PrimeArtifactBinding
    public let deviceID: UInt64
    public let inode: UInt64
    public let actualMode: UInt16
}

/// A trusted directory descriptor used as the root for every artifact lookup.
///
/// Relative components are opened one at a time with `openat` and
/// `O_NOFOLLOW`. No validation or publication operation reconstructs an
/// absolute child path after this descriptor has been opened.
public final class PrimeArtifactRoot: @unchecked Sendable {
    private enum TrustedDescriptorKind {
        case directory
        case artifact

        func error(
            path: String
        ) -> PrimeDurableArtifactError {
            switch self {
            case .directory:
                .untrustedDirectory(path)
            case .artifact:
                .unsafeArtifact(path)
            }
        }
    }

    private static let permittedSystemExtendedAttributes:
        Set<String> = [
            // APFS/macOS may attach this opaque provenance marker to files
            // created by a signed process. It does not grant filesystem
            // access; ACLs and mode bits remain separately fail-closed.
            "com.apple.provenance",
        ]

    private let descriptor: Int32
    public let directoryURL: URL

    public init(directoryURL: URL) throws {
        guard directoryURL.isFileURL else {
            throw PrimeDurableArtifactError.untrustedDirectory(
                directoryURL.absoluteString
            )
        }
        let opened = try Self.openAbsoluteDirectory(
            at: directoryURL.path
        )
        do {
            try Self.requireTrustedDirectory(
                opened,
                path: directoryURL.path
            )
        } catch {
            _ = close(opened)
            throw error
        }
        descriptor = opened
        self.directoryURL = directoryURL
    }

    deinit {
        _ = close(descriptor)
    }

    /// Duplicates the already-admitted artifact-root capability.
    ///
    /// Inventory code must start from this descriptor rather than reopening
    /// `directoryURL`, which is telemetry after root admission.
    func duplicateTrustedRootDescriptorForInventory()
        throws -> Int32
    {
        let duplicated = fcntl(
            descriptor,
            F_DUPFD_CLOEXEC,
            0
        )
        guard duplicated >= 0 else {
            throw Self.posix(
                "duplicate trusted artifact root for inventory",
                directoryURL.path
            )
        }
        do {
            try Self.requireTrustedDirectory(
                duplicated,
                path: directoryURL.path
            )
        } catch {
            _ = close(duplicated)
            throw error
        }
        return duplicated
    }

    static func requireTrustedInventoryDirectoryDescriptor(
        _ descriptor: Int32,
        path: String
    ) throws {
        try requireTrustedDirectory(
            descriptor,
            path: path
        )
    }

    static func requireTrustedInventoryArtifactDescriptor(
        _ descriptor: Int32,
        path: String
    ) throws {
        try requireTrustedDescriptorMetadata(
            descriptor,
            path: path,
            kind: .artifact
        )
    }

    /// Requires an owner-only resolver root, not merely a root that is safe
    /// from group/world writes. Source snapshots and receipts can contain
    /// private research material, so this gate requires exact mode `0700`.
    public func requirePrivateRootMode() throws {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFDIR),
              metadata.st_uid == geteuid(),
              metadata.st_mode & mode_t(0o777)
                == mode_t(0o700) else {
            throw PrimeDurableArtifactError
                .untrustedDirectory(directoryURL.path)
        }
    }

    /// Requires a new run to begin in an empty descriptor-bound root.
    ///
    /// This prevents prior-run success or failure artifacts from being
    /// mistaken for evidence produced by the current supervisor invocation.
    public func requireEmpty() throws {
        let duplicate = dup(descriptor)
        guard duplicate >= 0,
              lseek(duplicate, 0, SEEK_SET) >= 0,
              let directory = fdopendir(duplicate) else {
            if duplicate >= 0 {
                _ = close(duplicate)
            }
            throw Self.posix(
                "enumerate artifact root",
                directoryURL.path
            )
        }
        defer {
            _ = closedir(directory)
        }
        errno = 0
        while let entry = readdir(directory) {
            let name = withUnsafePointer(
                to: entry.pointee.d_name
            ) {
                $0.withMemoryRebound(
                    to: CChar.self,
                    capacity: Int(MAXNAMLEN) + 1
                ) {
                    String(cString: $0)
                }
            }
            if name != ".", name != ".." {
                throw PrimeDurableArtifactError
                    .nonemptyArtifactRoot
            }
            errno = 0
        }
        guard errno == 0 else {
            throw Self.posix(
                "enumerate artifact root",
                directoryURL.path
            )
        }
    }

    /// Creates or verifies one descriptor-relative private directory.
    ///
    /// The directory is created beneath the already-open trusted root and is
    /// then reopened with `O_NOFOLLOW`. Existing directories must be owned by
    /// the effective user, have exact mode 0700, and pass the same ACL/xattr
    /// checks as the artifact root.
    public func ensurePrivateDirectory(
        at relativePath: String
    ) throws {
        let parsed = try Self.components(of: relativePath)
        try withParentDescriptor(
            components: parsed.parents,
            relativePath: relativePath
        ) { parent in
            let created = parsed.leaf.withCString {
                mkdirat(parent, $0, mode_t(0o700))
            }
            let creationError = errno
            guard created == 0
                    || creationError == EEXIST else {
                throw PrimeDurableArtifactError.posix(
                    operation:
                        "mkdirat private artifact directory",
                    path: relativePath,
                    code: creationError
                )
            }
            let opened = parsed.leaf.withCString {
                openat(
                    parent,
                    $0,
                    O_RDONLY | O_DIRECTORY
                        | O_NOFOLLOW | O_CLOEXEC
                )
            }
            guard opened >= 0 else {
                throw Self.posix(
                    "openat private artifact directory",
                    relativePath
                )
            }
            defer {
                _ = close(opened)
            }
            try Self.requireTrustedDirectory(
                opened,
                path: relativePath
            )
            var metadata = stat()
            guard fstat(opened, &metadata) == 0,
                  metadata.st_mode & mode_t(0o7777)
                    == mode_t(0o700) else {
                throw PrimeDurableArtifactError
                    .untrustedDirectory(relativePath)
            }
            if created == 0 {
                try Self.synchronize(
                    parent,
                    operation:
                        "synchronize private directory parent",
                    path: relativePath
                )
            }
        }
    }

    /// Fails before expensive work if an immutable output name is already
    /// occupied. Publication still uses exclusive no-replace semantics, so
    /// this is a spend guard rather than the final race authority.
    public func requireAbsent(
        at relativePath: String
    ) throws {
        let parsed = try Self.components(of: relativePath)
        try withParentDescriptor(
            components: parsed.parents,
            relativePath: relativePath
        ) { parent in
            var metadata = stat()
            let result = parsed.leaf.withCString {
                fstatat(
                    parent,
                    $0,
                    &metadata,
                    AT_SYMLINK_NOFOLLOW
                )
            }
            if result == 0 {
                throw PrimeDurableArtifactError
                    .conflictingArtifact(relativePath)
            }
            let statusError = errno
            guard statusError == ENOENT else {
                throw PrimeDurableArtifactError.posix(
                    operation:
                        "descriptor-relative output preflight",
                    path: relativePath,
                    code: statusError
                )
            }
        }
    }

    /// Produces a binding for an already-published safe artifact. This is used
    /// by the Swift supervisor to re-resolve a worker receipt after normal
    /// exit, thrown failure, signal termination, or process-level OOM.
    public func bindExisting(
        at relativePath: String,
        purpose: PrimeArtifactPurpose,
        maximumByteCount: UInt64 = 16 * 1024 * 1024
    ) throws -> PrimeArtifactBinding {
        let parsed = try Self.components(of: relativePath)
        return try withParentDescriptor(
            components: parsed.parents,
            relativePath: relativePath
        ) { parent in
            let opened = try openArtifact(
                parent: parent,
                leaf: parsed.leaf,
                relativePath: relativePath
            )
            defer {
                _ = close(opened)
            }
            var initial = stat()
            guard fstat(opened, &initial) == 0,
                  initial.st_size >= 0 else {
                throw Self.posix(
                    "fstat existing artifact",
                    relativePath
                )
            }
            let byteCount = UInt64(initial.st_size)
            guard byteCount <= maximumByteCount else {
                throw PrimeDurableArtifactError
                    .artifactTooLarge(relativePath)
            }
            let before = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: relativePath,
                purpose: purpose,
                expectedByteCount: byteCount
            )
            let digest = try Self.streamDigest(
                opened,
                path: relativePath,
                expectedByteCount: byteCount
            )
            let after = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: relativePath,
                purpose: purpose,
                expectedByteCount: byteCount
            )
            try Self.requireStableFile(
                before,
                after,
                path: relativePath
            )
            return PrimeArtifactBinding(
                relativePath: relativePath,
                sha256: digest.sha256,
                byteCount: byteCount,
                purpose: purpose
            )
        }
    }

    public func publish(
        _ data: Data,
        at relativePath: String,
        purpose: PrimeArtifactPurpose
    ) throws -> PrimeArtifactBinding {
        let parsed = try Self.components(of: relativePath)
        let existing = try withParentDescriptor(
            components: parsed.parents,
            relativePath: relativePath
        ) { parent in
            try verifyExisting(
                data,
                parent: parent,
                leaf: parsed.leaf,
                relativePath: relativePath,
                purpose: purpose
            )
        }
        if existing {
            return PrimeArtifactBinding(
                relativePath: relativePath,
                sha256: PrimeSHA256.hexDigest(of: data),
                byteCount: UInt64(data.count),
                purpose: purpose
            )
        }
        return try publishGeneratedFile(
            at: relativePath,
            purpose: purpose,
            maximumByteCount: UInt64(data.count)
        ) { descriptor in
            try Self.writeAll(
                data,
                descriptor: descriptor,
                path: relativePath
            )
        }
    }

    /// Publishes a file produced by a synchronous descriptor generator without
    /// materializing its bytes in `Data`.
    ///
    /// The generator receives a borrowed `CLOEXEC` duplicate for a hidden,
    /// precreated file in the destination directory. It must not close, retain,
    /// or use the descriptor after `generate` returns. The original descriptor
    /// and parent descriptor remain open across generation. The file is
    /// accepted only if the descriptor-relative name still resolves to that
    /// exact single-link inode after generation.
    ///
    /// `maximumByteCount` is a post-generation acceptance limit, not a write
    /// quota. The generator must enforce any resource or time limit while it
    /// writes; this method rejects an oversized final extent only after
    /// `generate` returns, reclaims the held inode's storage, and leaves a
    /// zero-length fail-closed marker if its hidden name remains bound.
    public func publishGeneratedFile(
        at relativePath: String,
        purpose: PrimeArtifactPurpose,
        maximumByteCount: UInt64,
        generate: (Int32) throws -> Void
    ) throws -> PrimeArtifactBinding {
        let parsed = try Self.components(of: relativePath)
        let temporaryName =
            ".prime-partial-\(UUID().uuidString)"
        return try withParentDescriptor(
            components: parsed.parents,
            relativePath: relativePath
        ) { parent in
            var existing = stat()
            let existingStatus = parsed.leaf.withCString {
                fstatat(
                    parent,
                    $0,
                    &existing,
                    AT_SYMLINK_NOFOLLOW
                )
            }
            if existingStatus == 0 {
                guard existing.st_mode & mode_t(S_IFMT)
                        == mode_t(S_IFREG) else {
                    throw PrimeDurableArtifactError
                        .unsafeArtifact(relativePath)
                }
                throw PrimeDurableArtifactError
                    .conflictingArtifact(relativePath)
            }
            let existingError = errno
            guard existingError == ENOENT else {
                throw PrimeDurableArtifactError.posix(
                    operation:
                        "descriptor-relative generated output preflight",
                    path: relativePath,
                    code: existingError
                )
            }

            let generated = temporaryName.withCString {
                openat(
                    parent,
                    $0,
                    O_RDWR | O_CREAT | O_EXCL
                        | O_NOFOLLOW | O_CLOEXEC,
                    mode_t(0o600)
                )
            }
            guard generated >= 0 else {
                throw Self.posix(
                    "openat generated artifact",
                    temporaryName
                )
            }

            var temporaryNeedsReclamation = true
            defer {
                _ = close(generated)
            }

            do {
                _ = try Self.regularFileMetadata(
                    generated,
                    parent: parent,
                    leaf: temporaryName,
                    path: temporaryName,
                    expectedMode: mode_t(0o600),
                    expectedByteCount: 0
                )
                try Self.withDuplicatedDescriptor(
                    generated,
                    operation:
                        "duplicate generated artifact descriptor",
                    path: relativePath,
                    body: generate
                )
                try Self.requireTrustedDirectory(
                    parent,
                    path: relativePath
                )
                let generatedMetadata =
                    try Self.regularFileMetadata(
                        generated,
                        parent: parent,
                        leaf: temporaryName,
                        path: temporaryName,
                        expectedMode: mode_t(0o600),
                        expectedByteCount: nil
                    )
                let byteCount = UInt64(
                    generatedMetadata.st_size
                )
                guard byteCount <= maximumByteCount else {
                    throw PrimeDurableArtifactError
                        .artifactTooLarge(relativePath)
                }
                guard fchmod(generated, purpose.mode) == 0 else {
                    throw Self.posix(
                        "fchmod generated artifact",
                        temporaryName
                    )
                }
                try Self.synchronize(
                    generated,
                    operation:
                        "synchronize generated artifact",
                    path: temporaryName
                )
                let beforeHash = try Self.artifactMetadata(
                    generated,
                    parent: parent,
                    leaf: temporaryName,
                    path: temporaryName,
                    purpose: purpose,
                    expectedByteCount: byteCount
                )
                let digest = try Self.streamDigest(
                    generated,
                    path: temporaryName,
                    expectedByteCount: byteCount
                )
                let afterHash = try Self.artifactMetadata(
                    generated,
                    parent: parent,
                    leaf: temporaryName,
                    path: temporaryName,
                    purpose: purpose,
                    expectedByteCount: byteCount
                )
                try Self.requireStableFile(
                    beforeHash,
                    afterHash,
                    path: temporaryName
                )
                let binding = PrimeArtifactBinding(
                    relativePath: relativePath,
                    sha256: digest.sha256,
                    byteCount: digest.byteCount,
                    purpose: purpose
                )

                let renamed = Self.renameNoReplace(
                    parent: parent,
                    source: temporaryName,
                    destination: parsed.leaf
                )
                let renameError = errno
                if renamed != 0 {
                    if renameError == EEXIST {
                        throw PrimeDurableArtifactError
                            .conflictingArtifact(relativePath)
                    } else {
                        throw PrimeDurableArtifactError.posix(
                            operation:
                                "exclusive generated artifact publication",
                            path: relativePath,
                            code: renameError
                        )
                    }
                } else {
                    temporaryNeedsReclamation = false
                    try Self.requireTrustedDirectory(
                        parent,
                        path: relativePath
                    )
                    try Self.synchronize(
                        parent,
                        operation:
                            "synchronize generated publication parent",
                        path: relativePath
                    )
                    let publishedBefore =
                        try Self.artifactMetadata(
                            generated,
                            parent: parent,
                            leaf: parsed.leaf,
                            path: relativePath,
                            purpose: purpose,
                            expectedByteCount: byteCount
                        )
                    try Self.requireStableFile(
                        afterHash,
                        publishedBefore,
                        path: relativePath,
                        compareStatusChangeTime: false
                    )
                    let publishedDigest =
                        try Self.streamDigest(
                            generated,
                            path: relativePath,
                            expectedByteCount: byteCount
                        )
                    guard publishedDigest.sha256
                            == binding.sha256 else {
                        throw PrimeDurableArtifactError.hashMismatch(
                            path: relativePath,
                            expected: binding.sha256,
                            actual: publishedDigest.sha256
                        )
                    }
                    let publishedAfter =
                        try Self.artifactMetadata(
                            generated,
                            parent: parent,
                            leaf: parsed.leaf,
                            path: relativePath,
                            purpose: purpose,
                            expectedByteCount: byteCount
                        )
                    try Self.requireStableFile(
                        publishedBefore,
                        publishedAfter,
                        path: relativePath
                    )
                }
                return binding
            } catch {
                let publicationError = error
                if temporaryNeedsReclamation {
                    // Never unlink this descriptor-relative name after a
                    // separate identity check. Another process could rebound
                    // the name between that check and unlinkat, causing
                    // unrelated data to be destroyed. Reclaim only the inode
                    // held by this descriptor and leave any still-bound,
                    // zero-length partial as explicit fail-closed debris.
                    temporaryNeedsReclamation = false
                    do {
                        try Self
                            .reclaimTemporaryArtifactStorage(
                                generated,
                                parent: parent,
                                leaf: temporaryName,
                                path: temporaryName
                            )
                    } catch {
                        throw error
                    }
                }
                throw publicationError
            }
        }
    }

    /// Opens and verifies an immutable artifact around a descriptor loader.
    ///
    /// `load` may return lazy state. `materialize` is therefore mandatory and
    /// runs before the held descriptor, descriptor-relative name, metadata,
    /// byte count, and SHA-256 are verified again. `load` receives a borrowed
    /// `CLOEXEC` duplicate which remains open through `materialize`. Neither
    /// closure may close, retain, or use it after `materialize` returns.
    public func withVerifiedArtifactDescriptor<Loaded, Result>(
        _ binding: PrimeArtifactBinding,
        load: (Int32) throws -> Loaded,
        materialize: (Loaded) throws -> Result
    ) throws -> Result {
        try binding.validateDeclaration()
        let parsed = try Self.components(
            of: binding.relativePath
        )
        return try withParentDescriptor(
            components: parsed.parents,
            relativePath: binding.relativePath
        ) { parent in
            let opened = try openArtifact(
                parent: parent,
                leaf: parsed.leaf,
                relativePath: binding.relativePath
            )
            defer { _ = close(opened) }

            let before = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: binding.relativePath,
                purpose: binding.purpose,
                expectedByteCount: binding.byteCount
            )
            let initialDigest = try Self.streamDigest(
                opened,
                path: binding.relativePath,
                expectedByteCount: binding.byteCount
            )
            guard initialDigest.sha256 == binding.sha256 else {
                throw PrimeDurableArtifactError.hashMismatch(
                    path: binding.relativePath,
                    expected: binding.sha256,
                    actual: initialDigest.sha256
                )
            }
            guard lseek(opened, 0, SEEK_SET) >= 0 else {
                throw Self.posix(
                    "seek verified artifact for loader",
                    binding.relativePath
                )
            }
            let result = try Self.withDuplicatedDescriptor(
                opened,
                operation:
                    "duplicate verified artifact descriptor",
                path: binding.relativePath
            ) { borrowed in
                let loaded = try load(borrowed)
                return try materialize(loaded)
            }

            try Self.requireTrustedDirectory(
                parent,
                path: binding.relativePath
            )
            let after = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: binding.relativePath,
                purpose: binding.purpose,
                expectedByteCount: binding.byteCount
            )
            try Self.requireStableFile(
                before,
                after,
                path: binding.relativePath
            )
            let finalDigest = try Self.streamDigest(
                opened,
                path: binding.relativePath,
                expectedByteCount: binding.byteCount
            )
            guard finalDigest.sha256 == binding.sha256 else {
                throw PrimeDurableArtifactError.hashMismatch(
                    path: binding.relativePath,
                    expected: binding.sha256,
                    actual: finalDigest.sha256
                )
            }
            let finalMetadata = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: binding.relativePath,
                purpose: binding.purpose,
                expectedByteCount: binding.byteCount
            )
            try Self.requireStableFile(
                after,
                finalMetadata,
                path: binding.relativePath
            )
            return result
        }
    }

    public func publishCanonical<Value: Encodable>(
        _ value: Value,
        at relativePath: String
    ) throws -> PrimeArtifactBinding {
        try publish(
            PrimeCanonicalJSON.encode(value),
            at: relativePath,
            purpose: .immutableData
        )
    }

    /// Publishes canonical JSON only if the destination does not already
    /// exist.
    ///
    /// Use this for terminal receipts whose exclusive creation is itself part
    /// of the temporal evidence. Unlike `publishCanonical`, a byte-identical
    /// pre-existing artifact is a conflict rather than an idempotent success.
    public func publishCanonicalExclusively<
        Value: Encodable
    >(
        _ value: Value,
        at relativePath: String
    ) throws -> PrimeArtifactBinding {
        let data = try PrimeCanonicalJSON.encode(value)
        return try publishGeneratedFile(
            at: relativePath,
            purpose: .immutableData,
            maximumByteCount: UInt64(data.count)
        ) { descriptor in
            try Self.writeAll(
                data,
                descriptor: descriptor,
                path: relativePath
            )
        }
    }

    public func verify(
        _ binding: PrimeArtifactBinding
    ) throws -> PrimeVerifiedArtifact {
        try binding.validateDeclaration()
        let parsed = try Self.components(
            of: binding.relativePath
        )
        return try withParentDescriptor(
            components: parsed.parents,
            relativePath: binding.relativePath
        ) { parent in
            let opened = try openArtifact(
                parent: parent,
                leaf: parsed.leaf,
                relativePath: binding.relativePath
            )
            defer { _ = close(opened) }

            let before = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: binding.relativePath,
                purpose: binding.purpose,
                expectedByteCount: binding.byteCount
            )
            let digest = try Self.streamDigest(
                opened,
                path: binding.relativePath,
                expectedByteCount: binding.byteCount
            )
            let after = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: binding.relativePath,
                purpose: binding.purpose,
                expectedByteCount: binding.byteCount
            )
            try Self.requireStableFile(
                before,
                after,
                path: binding.relativePath
            )
            guard digest.sha256 == binding.sha256 else {
                throw PrimeDurableArtifactError.hashMismatch(
                    path: binding.relativePath,
                    expected: binding.sha256,
                    actual: digest.sha256
                )
            }
            return PrimeVerifiedArtifact(
                binding: binding,
                deviceID: UInt64(bitPattern: Int64(after.st_dev)),
                inode: UInt64(after.st_ino),
                actualMode: UInt16(after.st_mode & mode_t(0o777))
            )
        }
    }

    public func readVerified(
        _ binding: PrimeArtifactBinding,
        maximumByteCount: UInt64 = 16 * 1024 * 1024
    ) throws -> Data {
        guard binding.byteCount <= maximumByteCount else {
            throw PrimeDurableArtifactError.artifactTooLarge(
                binding.relativePath
            )
        }
        try binding.validateDeclaration()
        let parsed = try Self.components(
            of: binding.relativePath
        )
        return try withParentDescriptor(
            components: parsed.parents,
            relativePath: binding.relativePath
        ) { parent in
            let opened = try openArtifact(
                parent: parent,
                leaf: parsed.leaf,
                relativePath: binding.relativePath
            )
            defer { _ = close(opened) }
            let before = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: binding.relativePath,
                purpose: binding.purpose,
                expectedByteCount: binding.byteCount
            )
            var data = Data()
            data.reserveCapacity(Int(binding.byteCount))
            var hasher = SHA256()
            var buffer = [UInt8](repeating: 0, count: 64 * 1024)
            while true {
                let count = buffer.withUnsafeMutableBytes {
                    read(
                        opened,
                        $0.baseAddress,
                        $0.count
                    )
                }
                if count < 0, errno == EINTR { continue }
                guard count >= 0 else {
                    throw Self.posix(
                        "read artifact",
                        binding.relativePath
                    )
                }
                if count == 0 { break }
                let chunk = Data(buffer[0..<count])
                hasher.update(data: chunk)
                data.append(chunk)
                guard UInt64(data.count) <= maximumByteCount else {
                    throw PrimeDurableArtifactError.artifactTooLarge(
                        binding.relativePath
                    )
                }
            }
            let after = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: binding.relativePath,
                purpose: binding.purpose,
                expectedByteCount: binding.byteCount
            )
            guard before.st_dev == after.st_dev,
                  before.st_ino == after.st_ino,
                  before.st_size == after.st_size else {
                throw PrimeDurableArtifactError.unsafeArtifact(
                    binding.relativePath
                )
            }
            let actualHash = PrimeSHA256.encode(
                hasher.finalize()
            )
            guard actualHash == binding.sha256 else {
                throw PrimeDurableArtifactError.hashMismatch(
                    path: binding.relativePath,
                    expected: binding.sha256,
                    actual: actualHash
                )
            }
            return data
        }
    }

    public func decodeVerified<Value: Codable>(
        _ type: Value.Type,
        binding: PrimeArtifactBinding,
        maximumByteCount: UInt64 = 16 * 1024 * 1024
    ) throws -> Value {
        let data = try readVerified(
            binding,
            maximumByteCount: maximumByteCount
        )
        return try PrimeCanonicalJSON.decode(
            type,
            from: data,
            artifact: binding.relativePath
        )
    }

    public func verifySeedProvenance(
        _ record: PrimeHistoricalSeedRecord
    ) throws {
        let provenance = record.provenance
        let parsed = try Self.components(
            of: provenance.artifactPath
        )
        let byteCount: UInt64 = try withParentDescriptor(
            components: parsed.parents,
            relativePath: provenance.artifactPath
        ) { parent in
            let opened = try openArtifact(
                parent: parent,
                leaf: parsed.leaf,
                relativePath: provenance.artifactPath
            )
            defer { _ = close(opened) }
            var metadata = stat()
            guard fstat(opened, &metadata) == 0,
                  metadata.st_size >= 0 else {
                throw Self.posix(
                    "fstat seed provenance",
                    provenance.artifactPath
                )
            }
            return UInt64(metadata.st_size)
        }
        let binding = PrimeArtifactBinding(
            relativePath: provenance.artifactPath,
            sha256: provenance.artifactSHA256.lowercased(),
            byteCount: byteCount,
            purpose: .immutableData
        )
        let data = try readVerified(binding)
        let document = try JSONSerialization.jsonObject(
            with: data
        )
        let path = provenance.fieldPath.split(
            separator: ".",
            omittingEmptySubsequences: false
        ).map(String.init)
        guard !path.isEmpty,
              path.allSatisfy({
                  !$0.isEmpty
                      && $0 != "."
                      && $0 != ".."
              }) else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "seed provenance field path is invalid: \(provenance.fieldPath)"
            )
        }
        var value: Any = document
        for component in path {
            guard let object = value as? [String: Any],
                  let child = object[component] else {
                throw PrimeDurableArtifactError.invalidSemantics(
                    "seed provenance field does not exist: \(provenance.fieldPath)"
                )
            }
            value = child
        }
        guard let number = value as? NSNumber,
              CFGetTypeID(number) != CFBooleanGetTypeID(),
              number.stringValue == String(record.value) else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "seed provenance field does not equal its declared UInt64 value: \(provenance.fieldPath)"
            )
        }
    }

    /// Opens an absolute directory path without ever following a pathname
    /// component after the trusted filesystem root descriptor is acquired.
    ///
    /// `O_NOFOLLOW` on one absolute `open` protects only the final component.
    /// Walking every component relative to the descriptor held from the
    /// previous step prevents an intermediate symlink swap from redirecting
    /// the artifact root between argument validation and descriptor capture.
    private static func openAbsoluteDirectory(
        at path: String
    ) throws -> Int32 {
        let walkedPath =
            normalizedSystemRootAlias(path)
        let components = walkedPath.split(
            separator: "/",
            omittingEmptySubsequences: true
        ).map(String.init)
        guard walkedPath.hasPrefix("/"),
              !walkedPath.utf8.contains(0),
              walkedPath == "/"
                + components.joined(separator: "/"),
              components.allSatisfy({
                  $0 != "."
                      && $0 != ".."
                      && !$0.utf8.contains(0)
                      && $0.utf8.count <= 255
              }) else {
            throw PrimeDurableArtifactError
                .untrustedDirectory(path)
        }

        let flags =
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        var current = "/".withCString {
            open($0, flags)
        }
        guard current >= 0 else {
            throw posix(
                "open filesystem root",
                path
            )
        }

        for component in components {
            let next = component.withCString {
                openat(
                    current,
                    $0,
                    flags
                )
            }
            let openError = errno
            guard next >= 0 else {
                _ = close(current)
                throw PrimeDurableArtifactError.posix(
                    operation:
                        "openat trusted artifact root component",
                    path: path,
                    code: openError
                )
            }
            _ = close(current)
            current = next
        }
        return current
    }

    /// macOS exposes three fixed root aliases as root-owned symbolic links.
    /// Rewrite only those exact first components to their immutable system
    /// targets before the no-follow walk. No user-controlled or nested
    /// symbolic link is resolved by this compatibility rule.
    private static func normalizedSystemRootAlias(
        _ path: String
    ) -> String {
        #if os(macOS)
        for name in [
            "tmp",
            "var",
            "etc",
        ] {
            let alias = "/\(name)"
            if path == alias {
                return "/private/\(name)"
            }
            if path.hasPrefix(alias + "/") {
                return "/private/\(name)"
                    + String(
                        path.dropFirst(alias.utf8.count)
                    )
            }
        }
        #endif
        return path
    }

    fileprivate static func components(
        of relativePath: String
    ) throws -> (parents: ArraySlice<String>, leaf: String) {
        guard !relativePath.isEmpty,
              !relativePath.hasPrefix("/"),
              !relativePath.utf8.contains(0) else {
            throw PrimeDurableArtifactError.invalidRelativePath(
                relativePath
            )
        }
        let components = relativePath.split(
            separator: "/",
            omittingEmptySubsequences: false
        ).map(String.init)
        guard let leaf = components.last,
              !leaf.isEmpty,
              components.allSatisfy({
                  !$0.isEmpty
                      && $0 != "."
                      && $0 != ".."
                      && !$0.utf8.contains(0)
                      && $0.utf8.count <= 255
              }) else {
            throw PrimeDurableArtifactError.invalidRelativePath(
                relativePath
            )
        }
        return (components.dropLast(), leaf)
    }

    private static func requireStableFile(
        _ before: stat,
        _ after: stat,
        path: String,
        compareStatusChangeTime: Bool = true
    ) throws {
        let stableTimes: Bool
        #if canImport(Darwin)
        stableTimes =
            before.st_mtimespec.tv_sec
                == after.st_mtimespec.tv_sec
            && before.st_mtimespec.tv_nsec
                == after.st_mtimespec.tv_nsec
            && (
                !compareStatusChangeTime
                || (
                    before.st_ctimespec.tv_sec
                        == after.st_ctimespec.tv_sec
                    && before.st_ctimespec.tv_nsec
                        == after.st_ctimespec.tv_nsec
                )
            )
        #else
        stableTimes = !compareStatusChangeTime
        #endif
        guard before.st_dev == after.st_dev,
              before.st_ino == after.st_ino,
              before.st_size == after.st_size,
              stableTimes else {
            throw PrimeDurableArtifactError.unsafeArtifact(
                path
            )
        }
    }

    private static func streamDigest(
        _ descriptor: Int32,
        path: String,
        expectedByteCount: UInt64
    ) throws -> (
        sha256: String,
        byteCount: UInt64
    ) {
        guard lseek(descriptor, 0, SEEK_SET) >= 0 else {
            throw posix("seek artifact", path)
        }
        var hasher = SHA256()
        var total: UInt64 = 0
        var buffer = [UInt8](
            repeating: 0,
            count: 1024 * 1024
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
                throw posix("read artifact", path)
            }
            if count == 0 {
                break
            }
            let (next, overflow) = total.addingReportingOverflow(
                UInt64(count)
            )
            guard !overflow,
                  next <= expectedByteCount else {
                throw PrimeDurableArtifactError
                    .byteCountMismatch(
                        path: path,
                        expected: expectedByteCount,
                        actual: overflow
                            ? UInt64.max : next
                    )
            }
            hasher.update(
                data: Data(buffer[0 ..< count])
            )
            total = next
        }
        guard total == expectedByteCount else {
            throw PrimeDurableArtifactError.byteCountMismatch(
                path: path,
                expected: expectedByteCount,
                actual: total
            )
        }
        return (
            PrimeSHA256.encode(hasher.finalize()),
            total
        )
    }

    private static func withDuplicatedDescriptor<Result>(
        _ descriptor: Int32,
        operation: String,
        path: String,
        body: (Int32) throws -> Result
    ) throws -> Result {
        let duplicated = fcntl(
            descriptor,
            F_DUPFD_CLOEXEC,
            0
        )
        guard duplicated >= 0 else {
            throw posix(operation, path)
        }
        defer { _ = close(duplicated) }
        return try body(duplicated)
    }

    private func withParentDescriptor<Result>(
        components: ArraySlice<String>,
        relativePath: String,
        operation: (Int32) throws -> Result
    ) throws -> Result {
        let duplicated = dup(descriptor)
        guard duplicated >= 0 else {
            throw Self.posix(
                "dup artifact root",
                directoryURL.path
            )
        }
        _ = fcntl(duplicated, F_SETFD, FD_CLOEXEC)
        var current = duplicated
        defer { _ = close(current) }
        try Self.requireTrustedDirectory(
            current,
            path: directoryURL.path
        )

        for component in components {
            let next = component.withCString {
                openat(
                    current,
                    $0,
                    O_RDONLY | O_DIRECTORY
                        | O_NOFOLLOW | O_CLOEXEC
                )
            }
            guard next >= 0 else {
                throw Self.posix(
                    "openat artifact parent",
                    relativePath
                )
            }
            do {
                try Self.requireTrustedDirectory(
                    next,
                    path: relativePath
                )
            } catch {
                _ = close(next)
                throw error
            }
            _ = close(current)
            current = next
        }
        return try operation(current)
    }

    private func openArtifact(
        parent: Int32,
        leaf: String,
        relativePath: String
    ) throws -> Int32 {
        let opened = leaf.withCString {
            openat(
                parent,
                $0,
                O_RDONLY | O_NONBLOCK
                    | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard opened >= 0 else {
            throw Self.posix(
                "openat artifact",
                relativePath
            )
        }
        return opened
    }

    private func verifyExisting(
        _ expected: Data,
        parent: Int32,
        leaf: String,
        relativePath: String,
        purpose: PrimeArtifactPurpose
    ) throws -> Bool {
        let opened = leaf.withCString {
            openat(
                parent,
                $0,
                O_RDONLY | O_NONBLOCK
                    | O_NOFOLLOW | O_CLOEXEC
            )
        }
        if opened < 0 {
            if errno == ENOENT { return false }
            throw Self.posix(
                "openat existing artifact",
                relativePath
            )
        }
        defer { _ = close(opened) }

        let metadata: stat
        do {
            metadata = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: leaf,
                path: relativePath,
                purpose: purpose,
                expectedByteCount: UInt64(expected.count)
            )
        } catch PrimeDurableArtifactError
            .byteCountMismatch {
            throw PrimeDurableArtifactError
                .conflictingArtifact(relativePath)
        }
        guard metadata.st_size == expected.count else {
            throw PrimeDurableArtifactError.conflictingArtifact(
                relativePath
            )
        }
        var offset = 0
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        while offset < expected.count {
            let wanted = min(
                buffer.count,
                expected.count - offset
            )
            let count = buffer.withUnsafeMutableBytes {
                read(opened, $0.baseAddress, wanted)
            }
            if count < 0, errno == EINTR { continue }
            guard count > 0 else {
                if count < 0 {
                    throw Self.posix(
                        "read existing artifact",
                        relativePath
                    )
                }
                throw PrimeDurableArtifactError.conflictingArtifact(
                    relativePath
                )
            }
            let equal = expected.withUnsafeBytes {
                memcmp(
                    $0.baseAddress!.advanced(by: offset),
                    buffer,
                    count
                ) == 0
            }
            guard equal else {
                throw PrimeDurableArtifactError.conflictingArtifact(
                    relativePath
                )
            }
            offset += count
        }
        var trailing: UInt8 = 0
        let trailingCount = withUnsafeMutablePointer(to: &trailing) {
            read(opened, $0, 1)
        }
        guard trailingCount == 0 else {
            throw PrimeDurableArtifactError.conflictingArtifact(
                relativePath
            )
        }
        _ = try Self.artifactMetadata(
            opened,
            parent: parent,
            leaf: leaf,
            path: relativePath,
            purpose: purpose,
            expectedByteCount: UInt64(expected.count)
        )
        try Self.synchronize(
            opened,
            operation: "synchronize existing artifact",
            path: relativePath
        )
        try Self.synchronize(
            parent,
            operation: "synchronize existing artifact parent",
            path: relativePath
        )
        return true
    }

    private static func artifactMetadata(
        _ descriptor: Int32,
        parent: Int32,
        leaf: String,
        path: String,
        purpose: PrimeArtifactPurpose,
        expectedByteCount: UInt64
    ) throws -> stat {
        try regularFileMetadata(
            descriptor,
            parent: parent,
            leaf: leaf,
            path: path,
            expectedMode: purpose.mode,
            expectedByteCount: expectedByteCount
        )
    }

    private static func regularFileMetadata(
        _ descriptor: Int32,
        parent: Int32,
        leaf: String,
        path: String,
        expectedMode: mode_t,
        expectedByteCount: UInt64?
    ) throws -> stat {
        var opened = stat()
        guard fstat(descriptor, &opened) == 0 else {
            throw posix("fstat artifact", path)
        }
        var bound = stat()
        let boundStatus = leaf.withCString {
            fstatat(
                parent,
                $0,
                &bound,
                AT_SYMLINK_NOFOLLOW
            )
        }
        guard boundStatus == 0,
              opened.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              bound.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              opened.st_uid == geteuid(),
              bound.st_uid == geteuid(),
              opened.st_nlink == 1,
              bound.st_nlink == 1,
              opened.st_dev == bound.st_dev,
              opened.st_ino == bound.st_ino,
              opened.st_size >= 0,
              expectedByteCount.map({
                  UInt64(opened.st_size) == $0
              }) ?? true,
              opened.st_mode & mode_t(0o7777)
                == expectedMode,
              bound.st_mode & mode_t(0o7777)
                == expectedMode else {
            if let expectedByteCount,
               opened.st_size >= 0,
               UInt64(opened.st_size) != expectedByteCount {
                throw PrimeDurableArtifactError.byteCountMismatch(
                    path: path,
                    expected: expectedByteCount,
                    actual: UInt64(opened.st_size)
                )
            }
            throw PrimeDurableArtifactError.unsafeArtifact(path)
        }
        try requireStableFile(
            opened,
            bound,
            path: path
        )
        try requireTrustedDescriptorMetadata(
            descriptor,
            path: path,
            kind: .artifact
        )
        return opened
    }

    private static func requireTrustedArtifact(
        _ descriptor: Int32,
        parent: Int32,
        leaf: String,
        path: String,
        purpose: PrimeArtifactPurpose,
        expectedByteCount: UInt64
    ) throws {
        _ = try artifactMetadata(
            descriptor,
            parent: parent,
            leaf: leaf,
            path: path,
            purpose: purpose,
            expectedByteCount: expectedByteCount
        )
    }

    private static func requireTrustedDirectory(
        _ descriptor: Int32,
        path: String
    ) throws {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0 else {
            throw posix("fstat artifact directory", path)
        }
        guard metadata.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFDIR),
              metadata.st_uid == geteuid(),
              metadata.st_mode & mode_t(0o022) == 0,
              metadata.st_mode & mode_t(0o7000) == 0 else {
            throw PrimeDurableArtifactError.untrustedDirectory(path)
        }
        try requireTrustedDescriptorMetadata(
            descriptor,
            path: path,
            kind: .directory
        )
    }

    private static func requireTrustedDescriptorMetadata(
        _ descriptor: Int32,
        path: String,
        kind: TrustedDescriptorKind
    ) throws {
        #if canImport(Darwin)
        errno = 0
        if let accessControlList = acl_get_fd_np(
            descriptor,
            ACL_TYPE_EXTENDED
        ) {
            acl_free(
                UnsafeMutableRawPointer(
                    accessControlList
                )
            )
            throw kind.error(path: path)
        } else if errno != ENOENT {
            throw kind.error(path: path)
        }

        errno = 0
        let requiredSize = flistxattr(
            descriptor,
            nil,
            0,
            0
        )
        guard requiredSize >= 0,
              requiredSize <= 65_536 else {
            throw kind.error(path: path)
        }
        guard requiredSize > 0 else {
            return
        }

        var names = [CChar](
            repeating: 0,
            count: requiredSize
        )
        errno = 0
        let actualSize = names.withUnsafeMutableBufferPointer {
            flistxattr(
                descriptor,
                $0.baseAddress,
                $0.count,
                0
            )
        }
        guard actualSize == requiredSize else {
            throw kind.error(path: path)
        }

        let bytes = names.prefix(actualSize).map {
            UInt8(bitPattern: $0)
        }
        var start = bytes.startIndex
        var observedNames = Set<String>()
        for index in bytes.indices where bytes[index] == 0 {
            guard start < index,
                  let name = String(
                      bytes: bytes[start ..< index],
                      encoding: .utf8
                  ) else {
                throw kind.error(path: path)
            }
            observedNames.insert(name)
            start = bytes.index(after: index)
        }
        guard start == bytes.endIndex,
              observedNames.isSubset(
                  of: permittedSystemExtendedAttributes
              ) else {
            throw kind.error(path: path)
        }
        #else
        throw PrimeDurableArtifactError.unsupportedPlatform(
            "Prime artifact descriptor ACL/xattr validation requires Darwin"
        )
        #endif
    }

    /// Reclaims storage only from the inode held by `descriptor`.
    ///
    /// The descriptor-relative name is never unlinked: pathname identity can
    /// change after any separate `fstatat` check. A name still bound to this
    /// inode is preserved as a zero-length fail-closed marker. A missing name
    /// needs no further action, and a rebound name is preserved and rejected.
    private static func reclaimTemporaryArtifactStorage(
        _ descriptor: Int32,
        parent: Int32,
        leaf: String,
        path: String
    ) throws {
        var before = stat()
        guard fstat(descriptor, &before) == 0 else {
            throw posix(
                "fstat generated artifact reclamation",
                path
            )
        }
        guard before.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              before.st_uid == geteuid() else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(path)
        }
        guard ftruncate(descriptor, 0) == 0 else {
            throw posix(
                "truncate generated artifact reclamation",
                path
            )
        }
        guard fsync(descriptor) == 0 else {
            throw posix(
                "synchronize generated artifact reclamation",
                path
            )
        }
        var held = stat()
        guard fstat(descriptor, &held) == 0 else {
            throw posix(
                "fstat reclaimed generated artifact",
                path
            )
        }
        guard before.st_dev == held.st_dev,
              before.st_ino == held.st_ino,
              held.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              held.st_uid == geteuid(),
              held.st_size == 0 else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(path)
        }

        var bound = stat()
        let status = leaf.withCString {
            fstatat(
                parent,
                $0,
                &bound,
                AT_SYMLINK_NOFOLLOW
            )
        }
        if status != 0 {
            let statusError = errno
            if statusError == ENOENT {
                return
            }
            throw posix(
                "fstatat generated artifact reclamation",
                path,
                code: statusError
            )
        }
        guard held.st_dev == bound.st_dev,
              held.st_ino == bound.st_ino,
              held.st_nlink == 1,
              bound.st_nlink == 1,
              bound.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              bound.st_uid == geteuid(),
              bound.st_size == 0 else {
            throw PrimeDurableArtifactError.unsafeArtifact(
                path
            )
        }
    }

    private static func writeAll(
        _ data: Data,
        descriptor: Int32,
        path: String
    ) throws {
        if data.isEmpty { return }
        try data.withUnsafeBytes { bytes in
            guard let base = bytes.baseAddress else { return }
            var offset = 0
            while offset < bytes.count {
                let count = write(
                    descriptor,
                    base.advanced(by: offset),
                    bytes.count - offset
                )
                if count < 0, errno == EINTR { continue }
                guard count > 0 else {
                    throw posix("write artifact", path)
                }
                offset += count
            }
        }
    }

    private static func synchronize(
        _ descriptor: Int32,
        operation: String,
        path: String
    ) throws {
        guard fsync(descriptor) == 0 else {
            throw posix(operation, path)
        }
        #if canImport(Darwin)
        guard fcntl(descriptor, F_FULLFSYNC) == 0 else {
            throw posix("\(operation) F_FULLFSYNC", path)
        }
        #endif
    }

    private static func renameNoReplace(
        parent: Int32,
        source: String,
        destination: String
    ) -> Int32 {
        #if canImport(Darwin)
        return source.withCString { sourcePointer in
            destination.withCString { destinationPointer in
                renameatx_np(
                    parent,
                    sourcePointer,
                    parent,
                    destinationPointer,
                    UInt32(RENAME_EXCL)
                )
            }
        }
        #else
        errno = ENOTSUP
        return -1
        #endif
    }

    private static func posix(
        _ operation: String,
        _ path: String,
        code: Int32 = errno
    ) -> PrimeDurableArtifactError {
        .posix(
            operation: operation,
            path: path,
            code: code
        )
    }
}

public struct PrimeObservation<
    Value: Codable & Equatable & Sendable
>: Codable, Equatable, Sendable {
    public let observationAvailable: Bool
    public let value: Value?

    public init(
        observationAvailable: Bool,
        value: Value?
    ) {
        self.observationAvailable = observationAvailable
        self.value = value
    }

    public static func observed(
        _ value: Value
    ) -> Self {
        Self(observationAvailable: true, value: value)
    }

    public static var unavailable: Self {
        Self(observationAvailable: false, value: nil)
    }

    public func validate(_ label: String) throws {
        guard observationAvailable == (value != nil) else {
            throw PrimeDurableArtifactError.invalidObservation(
                "\(label) must use available+value or unavailable+null"
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case observationAvailable = "observation_available"
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        guard container.contains(.value) else {
            throw PrimeDurableArtifactError.invalidObservation(
                "the value key must be present so null and false remain distinct"
            )
        }
        observationAvailable = try container.decode(
            Bool.self,
            forKey: .observationAvailable
        )
        value = try container.decodeIfPresent(
            Value.self,
            forKey: .value
        )
        try validate("decoded observation")
    }

    public func encode(to encoder: Encoder) throws {
        try validate("encoded observation")
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )
        try container.encode(
            observationAvailable,
            forKey: .observationAvailable
        )
        if let value {
            try container.encode(value, forKey: .value)
        } else {
            try container.encodeNil(forKey: .value)
        }
    }
}

public typealias PrimeBooleanObservation =
    PrimeObservation<Bool>

private func validateReceiptSeeds(
    _ seeds: PrimeExecutionSeeds
) throws {
    let values = [
        seeds.initialization.value,
        seeds.trainingSchedule.value,
        seeds.evaluation.value,
    ]
    guard Set(values).count == 3 else {
        throw PrimeDurableArtifactError.invalidSemantics(
            "initialization, training-schedule, and evaluation seed values must be explicit and pairwise distinct"
        )
    }
}

public enum PrimeExecutionLanguage: String, Codable, Sendable {
    case swift = "Swift"
}

public struct PrimePinnedMLXMetallibBinding:
    Codable,
    Equatable,
    Sendable
{
    public let mlxSwiftVersion: String
    public let sourceBundleRelativePath: String
    public let artifact: PrimeArtifactBinding
    public let infoPlistSourceRelativePath: String
    public let infoPlistArtifact: PrimeArtifactBinding
    public let runtimeEnvironmentPolicy:
        PrimeMLXRuntimeEnvironmentPolicyDeclaration
    public let runtimeImageLayout:
        PrimeMLXRuntimeImageLayoutDeclaration
    public let releaseInstrumentationPolicy:
        PrimeReleaseInstrumentationAdmissionPolicyDeclaration

    public init(
        mlxSwiftVersion: String,
        sourceBundleRelativePath: String,
        artifact: PrimeArtifactBinding,
        infoPlistSourceRelativePath: String,
        infoPlistArtifact: PrimeArtifactBinding,
        runtimeEnvironmentPolicy:
            PrimeMLXRuntimeEnvironmentPolicyDeclaration,
        runtimeImageLayout:
            PrimeMLXRuntimeImageLayoutDeclaration,
        releaseInstrumentationPolicy:
            PrimeReleaseInstrumentationAdmissionPolicyDeclaration
    ) {
        self.mlxSwiftVersion = mlxSwiftVersion
        self.sourceBundleRelativePath =
            sourceBundleRelativePath
        self.artifact = artifact
        self.infoPlistSourceRelativePath =
            infoPlistSourceRelativePath
        self.infoPlistArtifact =
            infoPlistArtifact
        self.runtimeEnvironmentPolicy =
            runtimeEnvironmentPolicy
        self.runtimeImageLayout =
            runtimeImageLayout
        self.releaseInstrumentationPolicy =
            releaseInstrumentationPolicy
    }

    func validateDeclaration() throws {
        try artifact.validateDeclaration()
        try infoPlistArtifact.validateDeclaration()
        _ = try PrimeMLXRuntimeImageLayout.role(
            for: runtimeImageLayout
        )
        guard mlxSwiftVersion
                == PrimePinnedMLXMetallib.mlxSwiftVersion,
              sourceBundleRelativePath
                == PrimePinnedMLXMetallib
                    .sourceBundleRelativePath,
              artifact.relativePath
                == PrimePinnedMLXMetallib
                    .artifactRelativePath,
              artifact.purpose == .immutableData,
              artifact.byteCount
                == PrimePinnedMLXMetallib
                    .expectedByteCount,
              artifact.sha256
                == PrimePinnedMLXMetallib
                    .expectedSHA256,
              infoPlistSourceRelativePath
                == PrimePinnedMLXMetallib
                    .infoPlistSourceRelativePath,
              infoPlistArtifact.relativePath
                == PrimePinnedMLXMetallib
                    .infoPlistArtifactRelativePath,
              infoPlistArtifact.purpose
                == .immutableData,
              infoPlistArtifact.byteCount
                == PrimePinnedMLXMetallib
                    .expectedInfoPlistByteCount,
              infoPlistArtifact.sha256
                == PrimePinnedMLXMetallib
                    .expectedInfoPlistSHA256,
              runtimeEnvironmentPolicy
                == PrimeMLXRuntimeEnvironmentPolicy
                    .declaration,
              releaseInstrumentationPolicy
                == PrimeReleaseInstrumentationAdmissionPolicy
                    .declaration else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "the MLX bundle binding must name the frozen package version, exact bundle paths, immutable artifact paths, byte counts, and independently reproduced SHA-256 values"
            )
        }
    }
}

public struct PrimeExecutionArtifactBindings:
    Codable,
    Equatable,
    Sendable
{
    public let executable: PrimeArtifactBinding
    public let configuration: PrimeArtifactBinding
    public let sourceSnapshot: PrimeArtifactBinding
    public let mlxDefaultMetallib:
        PrimePinnedMLXMetallibBinding

    public init(
        executable: PrimeArtifactBinding,
        configuration: PrimeArtifactBinding,
        sourceSnapshot: PrimeArtifactBinding,
        mlxDefaultMetallib:
            PrimePinnedMLXMetallibBinding
    ) {
        self.executable = executable
        self.configuration = configuration
        self.sourceSnapshot = sourceSnapshot
        self.mlxDefaultMetallib =
            mlxDefaultMetallib
    }
}

public struct PrimeGPUCalibrationPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let armID: String
    public let batchSize: Int
    public let gradientAccumulationSteps: Int
    public let sequenceLength: Int
    public let optimizerSteps: Int
    public let workerActiveTimeLimitSeconds: Double
    public let supervisorEndToEndWallLimitSeconds: Double
    public let terminationGraceSeconds: Double
    public let requestedMLXMemoryLimitBytes: Int
    public let memoryCacheLimitBytes: Int
    public let optimizerImplementation: String
    public let optimizerPackageVersion: String
    public let optimizerLearningRate: Double
    public let optimizerBeta1: Double
    public let optimizerBeta2: Double
    public let optimizerEpsilon: Double
    public let optimizerWeightDecay: Double
    public let optimizerBiasCorrectionApplied: Bool
    public let mlxSwiftLMVersion: String
    public let functionalEvaluationAuthorized: Bool
    public let longTrainingAuthorized: Bool

    public static let initialAllocationProbe = Self(
        schemaVersion: 1,
        armID:
            "exact_3b_fp32_allocation_update_probe_b1_s128_a1",
        batchSize: 1,
        gradientAccumulationSteps: 1,
        sequenceLength: 128,
        optimizerSteps: 1,
        workerActiveTimeLimitSeconds: 1_800,
        supervisorEndToEndWallLimitSeconds: 1_800,
        terminationGraceSeconds: 10,
        requestedMLXMemoryLimitBytes:
            96 * 1024 * 1024 * 1024,
        memoryCacheLimitBytes: 512 * 1024 * 1024,
        optimizerImplementation: "MLXOptimizers.AdamW",
        optimizerPackageVersion: "0.31.3",
        optimizerLearningRate: 0.0001,
        optimizerBeta1: 0.9,
        optimizerBeta2: 0.999,
        optimizerEpsilon: 1e-8,
        optimizerWeightDecay: 0.01,
        optimizerBiasCorrectionApplied: false,
        mlxSwiftLMVersion: "3.31.3",
        functionalEvaluationAuthorized: false,
        longTrainingAuthorized: false
    )

    public init(
        schemaVersion: Int,
        armID: String,
        batchSize: Int,
        gradientAccumulationSteps: Int,
        sequenceLength: Int,
        optimizerSteps: Int,
        workerActiveTimeLimitSeconds: Double,
        supervisorEndToEndWallLimitSeconds: Double,
        terminationGraceSeconds: Double,
        requestedMLXMemoryLimitBytes: Int,
        memoryCacheLimitBytes: Int,
        optimizerImplementation: String,
        optimizerPackageVersion: String,
        optimizerLearningRate: Double,
        optimizerBeta1: Double,
        optimizerBeta2: Double,
        optimizerEpsilon: Double,
        optimizerWeightDecay: Double,
        optimizerBiasCorrectionApplied: Bool,
        mlxSwiftLMVersion: String,
        functionalEvaluationAuthorized: Bool,
        longTrainingAuthorized: Bool
    ) {
        self.schemaVersion = schemaVersion
        self.armID = armID
        self.batchSize = batchSize
        self.gradientAccumulationSteps =
            gradientAccumulationSteps
        self.sequenceLength = sequenceLength
        self.optimizerSteps = optimizerSteps
        self.workerActiveTimeLimitSeconds =
            workerActiveTimeLimitSeconds
        self.supervisorEndToEndWallLimitSeconds =
            supervisorEndToEndWallLimitSeconds
        self.terminationGraceSeconds =
            terminationGraceSeconds
        self.requestedMLXMemoryLimitBytes =
            requestedMLXMemoryLimitBytes
        self.memoryCacheLimitBytes =
            memoryCacheLimitBytes
        self.optimizerImplementation =
            optimizerImplementation
        self.optimizerPackageVersion =
            optimizerPackageVersion
        self.optimizerLearningRate =
            optimizerLearningRate
        self.optimizerBeta1 = optimizerBeta1
        self.optimizerBeta2 = optimizerBeta2
        self.optimizerEpsilon = optimizerEpsilon
        self.optimizerWeightDecay =
            optimizerWeightDecay
        self.optimizerBiasCorrectionApplied =
            optimizerBiasCorrectionApplied
        self.mlxSwiftLMVersion = mlxSwiftLMVersion
        self.functionalEvaluationAuthorized =
            functionalEvaluationAuthorized
        self.longTrainingAuthorized =
            longTrainingAuthorized
    }

    public func validate() throws {
        guard self == .initialAllocationProbe else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "only the frozen exact-3B FP32 initial allocation probe is currently admitted"
            )
        }
    }
}

public struct PrimeNative3BFP32ExecutionConfiguration:
    Codable,
    Equatable,
    Sendable
{
    public static let requiredPrimeSourceRelativePaths:
        Set<String> = [
            "Sources/PrimeGPUCalibration/PrimeGPUCalibrationMain.swift",
            "Sources/PrimeCore/PrimeNative3BProfile.swift",
        ]

    public let schemaVersion: Int
    public let profile: PrimeNativeModelProfile
    public let precision: PrimeNumericPrecision
    public let seeds: PrimeExecutionSeeds
    public let executable: PrimeArtifactBinding
    public let sourceSnapshot: PrimeArtifactBinding
    public let mlxDefaultMetallib:
        PrimePinnedMLXMetallibBinding
    public let calibrationPlan: PrimeGPUCalibrationPlan
    public let implementationLanguage: PrimeExecutionLanguage
    public let pythonExecutionAuthorized: Bool
    public let shellScientificAuthorityAuthorized: Bool
    public let externalExecutionExclusionReason: String

    public init(
        schemaVersion: Int = 2,
        profile: PrimeNativeModelProfile =
            PrimeNativeProfiles.exact3B,
        precision: PrimeNumericPrecision = .float32,
        seeds: PrimeExecutionSeeds,
        executable: PrimeArtifactBinding,
        sourceSnapshot: PrimeArtifactBinding,
        mlxDefaultMetallib:
            PrimePinnedMLXMetallibBinding,
        calibrationPlan: PrimeGPUCalibrationPlan =
            .initialAllocationProbe,
        implementationLanguage: PrimeExecutionLanguage =
            .swift,
        pythonExecutionAuthorized: Bool = false,
        shellScientificAuthorityAuthorized: Bool = false,
        externalExecutionExclusionReason: String
    ) {
        self.schemaVersion = schemaVersion
        self.profile = profile
        self.precision = precision
        self.seeds = seeds
        self.executable = executable
        self.sourceSnapshot = sourceSnapshot
        self.mlxDefaultMetallib =
            mlxDefaultMetallib
        self.calibrationPlan = calibrationPlan
        self.implementationLanguage = implementationLanguage
        self.pythonExecutionAuthorized =
            pythonExecutionAuthorized
        self.shellScientificAuthorityAuthorized =
            shellScientificAuthorityAuthorized
        self.externalExecutionExclusionReason =
            externalExecutionExclusionReason
    }

    public func validate() throws {
        guard schemaVersion == 2,
              profile == PrimeNativeProfiles.exact3B,
              precision == .float32,
              implementationLanguage == .swift else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "configuration must select the frozen native 3B FP32 Swift profile"
            )
        }
        try validateReceiptSeeds(seeds)
        try calibrationPlan.validate()
        try executable.validateDeclaration()
        try sourceSnapshot.validateDeclaration()
        try mlxDefaultMetallib.validateDeclaration()
        try PrimeMLXRuntimeImageLayout.require(
            mlxDefaultMetallib.runtimeImageLayout,
            for: .calibration
        )
        guard executable.purpose == .executable,
              sourceSnapshot.purpose == .immutableData,
              mlxDefaultMetallib.artifact.purpose
                == .immutableData,
              mlxDefaultMetallib
                .infoPlistArtifact.purpose
                == .immutableData else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "configuration artifact purposes are not executable+source+metallib"
            )
        }
        guard !pythonExecutionAuthorized,
              !shellScientificAuthorityAuthorized else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "Python execution and shell scientific authority are forbidden in the native lane"
            )
        }
        guard !externalExecutionExclusionReason
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "the Python/shell exclusion reason must be explicit"
            )
        }
    }
}

public enum PrimeReceiptStopReason:
    String,
    Codable,
    Sendable
{
    case mechanicsCompleted = "mechanics_completed"
    case calibrationBudgetReached =
        "calibration_budget_reached"
    case runBudgetReached = "run_budget_reached"
    case convergenceReached = "convergence_reached"
    case nonFiniteLoss = "non_finite_loss"
    case outOfMemory = "out_of_memory"
    case executorFailure = "executor_failure"
    case timeLimitReached = "time_limit_reached"
    case cancelled = "cancelled"
}

public enum PrimeGPUCalibrationOutcome:
    String,
    Codable,
    Sendable
{
    case grounded = "GROUNDED"
    case abstain = "ABSTAIN"
}

public struct PrimeGPUCalibrationMechanics:
    Codable,
    Equatable,
    Sendable
{
    public let forwardLogitsFinite: Bool
    public let initialEvaluationLoss: Double
    public let finalEvaluationLoss: Double
    public let stepLosses: [Double]
    public let firstGradientNorm: Double
    public let selectedParameterFingerprintBefore: String
    public let selectedParameterFingerprintAfter: String
    public let optimizerImplementation: String
    public let optimizerPackageVersion: String
    public let optimizerLearningRate: Double
    public let optimizerBeta1: Double
    public let optimizerBeta2: Double
    public let optimizerEpsilon: Double
    public let optimizerWeightDecay: Double
    public let optimizerBiasCorrectionApplied: Bool
    public let expectedOptimizerStateArrayCount: Int
    public let optimizerStateArrayCount: Int
    public let optimizerStateDTypes: [String]
    public let optimizerStateL2Norm: Double
    public let optimizerStepChangedWeights: Bool
    public let optimizerStateRestoreSupported: Bool

    public init(
        forwardLogitsFinite: Bool,
        initialEvaluationLoss: Double,
        finalEvaluationLoss: Double,
        stepLosses: [Double],
        firstGradientNorm: Double,
        selectedParameterFingerprintBefore: String,
        selectedParameterFingerprintAfter: String,
        optimizerImplementation: String,
        optimizerPackageVersion: String,
        optimizerLearningRate: Double,
        optimizerBeta1: Double,
        optimizerBeta2: Double,
        optimizerEpsilon: Double,
        optimizerWeightDecay: Double,
        optimizerBiasCorrectionApplied: Bool,
        expectedOptimizerStateArrayCount: Int,
        optimizerStateArrayCount: Int,
        optimizerStateDTypes: [String],
        optimizerStateL2Norm: Double,
        optimizerStepChangedWeights: Bool,
        optimizerStateRestoreSupported: Bool
    ) {
        self.forwardLogitsFinite = forwardLogitsFinite
        self.initialEvaluationLoss = initialEvaluationLoss
        self.finalEvaluationLoss = finalEvaluationLoss
        self.stepLosses = stepLosses
        self.firstGradientNorm = firstGradientNorm
        self.selectedParameterFingerprintBefore =
            selectedParameterFingerprintBefore
        self.selectedParameterFingerprintAfter =
            selectedParameterFingerprintAfter
        self.optimizerImplementation =
            optimizerImplementation
        self.optimizerPackageVersion =
            optimizerPackageVersion
        self.optimizerLearningRate =
            optimizerLearningRate
        self.optimizerBeta1 = optimizerBeta1
        self.optimizerBeta2 = optimizerBeta2
        self.optimizerEpsilon = optimizerEpsilon
        self.optimizerWeightDecay =
            optimizerWeightDecay
        self.optimizerBiasCorrectionApplied =
            optimizerBiasCorrectionApplied
        self.expectedOptimizerStateArrayCount =
            expectedOptimizerStateArrayCount
        self.optimizerStateArrayCount =
            optimizerStateArrayCount
        self.optimizerStateDTypes =
            optimizerStateDTypes
        self.optimizerStateL2Norm =
            optimizerStateL2Norm
        self.optimizerStepChangedWeights =
            optimizerStepChangedWeights
        self.optimizerStateRestoreSupported =
            optimizerStateRestoreSupported
    }

    fileprivate func validate() throws {
        guard forwardLogitsFinite,
              initialEvaluationLoss.isFinite,
              finalEvaluationLoss.isFinite,
              initialEvaluationLoss >= 0,
              finalEvaluationLoss >= 0,
              !stepLosses.isEmpty,
              stepLosses.allSatisfy({
                  $0.isFinite && $0 >= 0
              }),
              firstGradientNorm.isFinite,
              firstGradientNorm > 0,
              !selectedParameterFingerprintBefore.isEmpty,
              !selectedParameterFingerprintAfter.isEmpty,
              selectedParameterFingerprintBefore
                != selectedParameterFingerprintAfter,
              optimizerImplementation
                == "MLXOptimizers.AdamW",
              optimizerPackageVersion == "0.31.3",
              optimizerLearningRate == 0.0001,
              optimizerBeta1 == 0.9,
              optimizerBeta2 == 0.999,
              optimizerEpsilon == 1e-8,
              optimizerWeightDecay == 0.01,
              !optimizerBiasCorrectionApplied,
              expectedOptimizerStateArrayCount == 508,
              optimizerStateArrayCount == 508,
              optimizerStateDTypes == ["float32"],
              optimizerStateL2Norm.isFinite,
              optimizerStateL2Norm > 0,
              optimizerStepChangedWeights,
              !optimizerStateRestoreSupported else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "GPU calibration mechanics are incomplete or divergent"
            )
        }
    }
}

public struct PrimeGPUCalibrationBoundary:
    Codable,
    Equatable,
    Sendable
{
    public let implementationLanguage:
        PrimeExecutionLanguage
    public let orchestrationLanguage:
        PrimeExecutionLanguage
    public let pythonExecution:
        PrimeBooleanObservation
    public let shellScientificAuthority:
        PrimeBooleanObservation
    public let pinnedDependencyShellCapabilityPresent:
        Bool
    public let dependencyShellExecution:
        PrimeBooleanObservation
    public let externalExecutionExclusionReason: String

    public init(
        implementationLanguage: PrimeExecutionLanguage =
            .swift,
        orchestrationLanguage: PrimeExecutionLanguage =
            .swift,
        pythonExecution: PrimeBooleanObservation =
            .observed(false),
        shellScientificAuthority: PrimeBooleanObservation =
            .observed(false),
        pinnedDependencyShellCapabilityPresent:
            Bool = true,
        dependencyShellExecution:
            PrimeBooleanObservation = .unavailable,
        externalExecutionExclusionReason: String
    ) {
        self.implementationLanguage = implementationLanguage
        self.orchestrationLanguage = orchestrationLanguage
        self.pythonExecution = pythonExecution
        self.shellScientificAuthority =
            shellScientificAuthority
        self.pinnedDependencyShellCapabilityPresent =
            pinnedDependencyShellCapabilityPresent
        self.dependencyShellExecution =
            dependencyShellExecution
        self.externalExecutionExclusionReason =
            externalExecutionExclusionReason
    }

    fileprivate func validate() throws {
        try pythonExecution.validate(
            "GPU calibration Python execution"
        )
        try shellScientificAuthority.validate(
            "GPU calibration shell scientific authority"
        )
        try dependencyShellExecution.validate(
            "pinned dependency shell execution"
        )
        guard implementationLanguage == .swift,
              orchestrationLanguage == .swift,
              pythonExecution.observationAvailable,
              pythonExecution.value == false,
              shellScientificAuthority
                .observationAvailable,
              shellScientificAuthority.value == false,
              pinnedDependencyShellCapabilityPresent,
              !dependencyShellExecution
                .observationAvailable,
              dependencyShellExecution.value == nil,
              !externalExecutionExclusionReason
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "GPU calibration must be Swift-authoritative, disclose the pinned MLX CPU-JIT shell capability, and leave its untraced invocation unavailable"
            )
        }
    }
}

public enum PrimeGPUWorkerTerminationReason:
    String,
    Codable,
    Sendable
{
    case exit
    case uncaughtSignal = "uncaught_signal"
}

/// Supervisor-only facts required to promote an immutable worker candidate
/// into an authoritative grounded calibration receipt.
public struct PrimeGPUSupervisorAttestation:
    Codable,
    Equatable,
    Sendable
{
    public let workerCandidate: PrimeArtifactBinding
    public let supervisorEndToEndWallSeconds: Double
    public let workerTerminationReason:
        PrimeGPUWorkerTerminationReason
    public let workerTerminationStatus: Int32
    public let hardTimeoutObserved: Bool
    public let capabilityVerified: Bool
    public let runAuthorityLeaseHeld: Bool

    public init(
        workerCandidate: PrimeArtifactBinding,
        supervisorEndToEndWallSeconds: Double,
        workerTerminationReason:
            PrimeGPUWorkerTerminationReason,
        workerTerminationStatus: Int32,
        hardTimeoutObserved: Bool,
        capabilityVerified: Bool,
        runAuthorityLeaseHeld: Bool
    ) {
        self.workerCandidate = workerCandidate
        self.supervisorEndToEndWallSeconds =
            supervisorEndToEndWallSeconds
        self.workerTerminationReason =
            workerTerminationReason
        self.workerTerminationStatus =
            workerTerminationStatus
        self.hardTimeoutObserved =
            hardTimeoutObserved
        self.capabilityVerified = capabilityVerified
        self.runAuthorityLeaseHeld =
            runAuthorityLeaseHeld
    }

    fileprivate func validate(
        plan: PrimeGPUCalibrationPlan
    ) throws {
        try workerCandidate.validateDeclaration()
        guard workerCandidate.purpose == .immutableData,
              supervisorEndToEndWallSeconds.isFinite,
              supervisorEndToEndWallSeconds > 0,
              supervisorEndToEndWallSeconds
                <= plan
                    .supervisorEndToEndWallLimitSeconds,
              workerTerminationReason == .exit,
              workerTerminationStatus == 0,
              !hardTimeoutObserved,
              capabilityVerified,
              runAuthorityLeaseHeld else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "grounded calibration requires a clean, in-budget, capability-bound supervisor attestation under the run-authority lease"
            )
        }
    }
}

/// The public factual receipt emitted by the bounded 3B FP32 Metal
/// allocation/forward/backward/update calibration.
///
/// `MLXOptimizers.AdamW` names the maintained Swift optimizer API. It does
/// not imply a Python process, Python binding, or Python-authored mutation.
public struct PrimeGPUCalibrationReceipt:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let outcome: PrimeGPUCalibrationOutcome
    public let claimScope: String
    public let recordedAtUTC: String
    public let profile: PrimeNativeModelProfile
    public let expectedParameterCount: Int64
    public let observedParameterCount: Int64
    public let precision: PrimeNumericPrecision
    public let observedParameterDTypes: [String]
    public let parameterCountMatches: Bool
    public let allParametersFP32: Bool
    public let seeds: PrimeExecutionSeeds
    public let artifacts: PrimeExecutionArtifactBindings
    public let deviceType: String
    public let deviceDescription: String
    public let deviceArchitecture: String
    public let deviceMemoryBytes: UInt64
    public let deviceMaxRecommendedWorkingSetBytes:
        UInt64
    public let deviceMaxBufferBytes: UInt64
    public let batchSize: Int
    public let gradientAccumulationSteps: Int
    public let sequenceLength: Int
    public let completedSteps: Int
    public let processedPaddedTokenPositions: UInt64
    public let supervisedTargetTokenCount: UInt64
    public let mechanicsActiveElapsedSeconds: Double
    public let peakActiveMemoryBytes: UInt64
    public let mechanics: PrimeGPUCalibrationMechanics
    public let boundary: PrimeGPUCalibrationBoundary
    public let supervisorAttestation:
        PrimeGPUSupervisorAttestation?
    public let stopReason: PrimeReceiptStopReason
    public let functionalAutoregressiveOutputCount: Int
    public let longTrainingAuthorized: Bool
    public let nextAction: String

    public init(
        schemaVersion: Int = 2,
        outcome: PrimeGPUCalibrationOutcome,
        claimScope: String,
        recordedAtUTC: String,
        profile: PrimeNativeModelProfile =
            PrimeNativeProfiles.exact3B,
        expectedParameterCount: Int64,
        observedParameterCount: Int64,
        precision: PrimeNumericPrecision = .float32,
        observedParameterDTypes: [String],
        parameterCountMatches: Bool,
        allParametersFP32: Bool,
        seeds: PrimeExecutionSeeds,
        artifacts: PrimeExecutionArtifactBindings,
        deviceType: String,
        deviceDescription: String,
        deviceArchitecture: String,
        deviceMemoryBytes: UInt64,
        deviceMaxRecommendedWorkingSetBytes: UInt64,
        deviceMaxBufferBytes: UInt64,
        batchSize: Int,
        gradientAccumulationSteps: Int,
        sequenceLength: Int,
        completedSteps: Int,
        processedPaddedTokenPositions: UInt64,
        supervisedTargetTokenCount: UInt64,
        mechanicsActiveElapsedSeconds: Double,
        peakActiveMemoryBytes: UInt64,
        mechanics: PrimeGPUCalibrationMechanics,
        boundary: PrimeGPUCalibrationBoundary,
        supervisorAttestation:
            PrimeGPUSupervisorAttestation? = nil,
        stopReason: PrimeReceiptStopReason,
        functionalAutoregressiveOutputCount: Int,
        longTrainingAuthorized: Bool,
        nextAction: String
    ) {
        self.schemaVersion = schemaVersion
        artifactKind =
            "ergentics_prime_3b_fp32_gpu_mechanics_calibration_v2"
        self.outcome = outcome
        self.claimScope = claimScope
        self.recordedAtUTC = recordedAtUTC
        self.profile = profile
        self.expectedParameterCount =
            expectedParameterCount
        self.observedParameterCount =
            observedParameterCount
        self.precision = precision
        self.observedParameterDTypes =
            observedParameterDTypes
        self.parameterCountMatches =
            parameterCountMatches
        self.allParametersFP32 = allParametersFP32
        self.seeds = seeds
        self.artifacts = artifacts
        self.deviceType = deviceType
        self.deviceDescription = deviceDescription
        self.deviceArchitecture = deviceArchitecture
        self.deviceMemoryBytes = deviceMemoryBytes
        self.deviceMaxRecommendedWorkingSetBytes =
            deviceMaxRecommendedWorkingSetBytes
        self.deviceMaxBufferBytes =
            deviceMaxBufferBytes
        self.batchSize = batchSize
        self.gradientAccumulationSteps =
            gradientAccumulationSteps
        self.sequenceLength = sequenceLength
        self.completedSteps = completedSteps
        self.processedPaddedTokenPositions =
            processedPaddedTokenPositions
        self.supervisedTargetTokenCount =
            supervisedTargetTokenCount
        self.mechanicsActiveElapsedSeconds =
            mechanicsActiveElapsedSeconds
        self.peakActiveMemoryBytes =
            peakActiveMemoryBytes
        self.mechanics = mechanics
        self.boundary = boundary
        self.supervisorAttestation =
            supervisorAttestation
        self.stopReason = stopReason
        self.functionalAutoregressiveOutputCount =
            functionalAutoregressiveOutputCount
        self.longTrainingAuthorized =
            longTrainingAuthorized
        self.nextAction = nextAction
    }

    private func validateMechanicsContent(
        in root: PrimeArtifactRoot
    ) throws -> PrimeGPUCalibrationPlan {
        guard schemaVersion == 2,
              artifactKind
                == "ergentics_prime_3b_fp32_gpu_mechanics_calibration_v2",
              outcome == .grounded,
              profile == PrimeNativeProfiles.exact3B,
              expectedParameterCount
                == PrimeNativeProfiles.exact3B
                    .parameterCount,
              observedParameterCount
                == expectedParameterCount,
              parameterCountMatches,
              precision == .float32,
              observedParameterDTypes == ["float32"],
              allParametersFP32,
              deviceType.lowercased() == "gpu",
              !deviceDescription.isEmpty,
              !deviceArchitecture.isEmpty,
              deviceArchitecture != "Unknown",
              deviceMemoryBytes > 0,
              deviceMaxRecommendedWorkingSetBytes > 0,
              deviceMaxRecommendedWorkingSetBytes
                <= deviceMemoryBytes,
              deviceMaxBufferBytes > 0,
              batchSize > 0,
              gradientAccumulationSteps > 0,
              sequenceLength > 1,
              completedSteps > 0,
              processedPaddedTokenPositions > 0,
              supervisedTargetTokenCount > 0,
              mechanicsActiveElapsedSeconds.isFinite,
              mechanicsActiveElapsedSeconds > 0,
              peakActiveMemoryBytes > 0,
              stopReason == .mechanicsCompleted,
              functionalAutoregressiveOutputCount == 0,
              !longTrainingAuthorized,
              !claimScope.isEmpty,
              !recordedAtUTC.isEmpty,
              !nextAction.isEmpty else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "GPU calibration receipt is not a grounded, bounded exact-3B FP32 mechanics result"
            )
        }
        let configuration = try root.decodeVerified(
            PrimeNative3BFP32ExecutionConfiguration.self,
            binding: artifacts.configuration
        )
        try configuration.validate()
        let plan = configuration.calibrationPlan
        let (stepBatch, overflow1) =
            UInt64(completedSteps)
                .multipliedReportingOverflow(
                    by: UInt64(batchSize)
                )
        let (stepBatchAccumulation, overflow2) =
            stepBatch.multipliedReportingOverflow(
                by: UInt64(gradientAccumulationSteps)
            )
        let (expectedPositions, overflow3) =
            stepBatchAccumulation
                .multipliedReportingOverflow(
                    by: UInt64(sequenceLength)
                )
        let (supervisedStepBatch, overflow4) =
            UInt64(completedSteps)
                .multipliedReportingOverflow(
                    by: UInt64(batchSize)
                )
        let (supervisedStepBatchAccumulation, overflow5) =
            supervisedStepBatch
                .multipliedReportingOverflow(
                    by: UInt64(
                        gradientAccumulationSteps
                    )
                )
        let (expectedSupervisedTargets, overflow6) =
            supervisedStepBatchAccumulation
                .multipliedReportingOverflow(
                    by: UInt64(sequenceLength - 1)
                )
        guard !overflow1,
              !overflow2,
              !overflow3,
              !overflow4,
              !overflow5,
              !overflow6,
              expectedPositions
                == processedPaddedTokenPositions,
              expectedSupervisedTargets
                == supervisedTargetTokenCount,
              mechanics.stepLosses.count
                == completedSteps,
              batchSize == plan.batchSize,
              gradientAccumulationSteps
                == plan.gradientAccumulationSteps,
              sequenceLength == plan.sequenceLength,
              completedSteps == plan.optimizerSteps,
              mechanicsActiveElapsedSeconds
                <= plan.workerActiveTimeLimitSeconds,
              UInt64(
                  plan.requestedMLXMemoryLimitBytes
              ) <= deviceMaxRecommendedWorkingSetBytes,
              peakActiveMemoryBytes <= UInt64(
                  plan.requestedMLXMemoryLimitBytes
              ),
              mechanics.optimizerImplementation
                == plan.optimizerImplementation,
              mechanics.optimizerPackageVersion
                == plan.optimizerPackageVersion,
              mechanics.optimizerLearningRate
                == plan.optimizerLearningRate,
              mechanics.optimizerBeta1
                == plan.optimizerBeta1,
              mechanics.optimizerBeta2
                == plan.optimizerBeta2,
              mechanics.optimizerEpsilon
                == plan.optimizerEpsilon,
              mechanics.optimizerWeightDecay
                == plan.optimizerWeightDecay,
              mechanics.optimizerBiasCorrectionApplied
                == plan.optimizerBiasCorrectionApplied,
              functionalAutoregressiveOutputCount == 0,
              !plan.functionalEvaluationAuthorized,
              longTrainingAuthorized
                == plan.longTrainingAuthorized else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "GPU calibration receipt diverges from its frozen plan"
            )
        }
        try validateReceiptSeeds(seeds)
        try mechanics.validate()
        try boundary.validate()
        return plan
    }

    /// Validates the worker's immutable mechanics claim without promoting it
    /// to authoritative grounded evidence.
    public func validateWorkerCandidate(
        in root: PrimeArtifactRoot
    ) throws {
        guard supervisorAttestation == nil else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "a worker candidate cannot contain supervisor attestation"
            )
        }
        _ = try validateMechanicsContent(in: root)
        let evidence = durableEvidence
        try evidence.validateDeclarations()
        try PrimeReceiptAuthorization.validateEvidence(
            evidence,
            in: root
        )
    }

    /// Validates a supervisor-finalized grounded receipt. A worker candidate
    /// can never pass this authority boundary on its own.
    public func validate(in root: PrimeArtifactRoot) throws {
        guard let supervisorAttestation else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "grounded calibration receipt lacks supervisor attestation"
            )
        }
        let plan = try validateMechanicsContent(in: root)
        try supervisorAttestation.validate(plan: plan)
        let candidate = try root.decodeVerified(
            PrimeGPUCalibrationReceipt.self,
            binding:
                supervisorAttestation.workerCandidate
        )
        try candidate.validateWorkerCandidate(in: root)
        guard self == candidate.finalized(
            with: supervisorAttestation
        ) else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "supervisor-finalized receipt does not exactly equal its immutable worker candidate plus attestation"
            )
        }
        let evidence = durableEvidence
        try evidence.validateDeclarations()
        try PrimeReceiptAuthorization.validateEvidence(
            evidence,
            in: root
        )
    }

    public func finalized(
        with supervisorAttestation:
            PrimeGPUSupervisorAttestation
    ) -> Self {
        Self(
            schemaVersion: schemaVersion,
            outcome: outcome,
            claimScope: claimScope,
            recordedAtUTC: recordedAtUTC,
            profile: profile,
            expectedParameterCount:
                expectedParameterCount,
            observedParameterCount:
                observedParameterCount,
            precision: precision,
            observedParameterDTypes:
                observedParameterDTypes,
            parameterCountMatches:
                parameterCountMatches,
            allParametersFP32: allParametersFP32,
            seeds: seeds,
            artifacts: artifacts,
            deviceType: deviceType,
            deviceDescription: deviceDescription,
            deviceArchitecture: deviceArchitecture,
            deviceMemoryBytes: deviceMemoryBytes,
            deviceMaxRecommendedWorkingSetBytes:
                deviceMaxRecommendedWorkingSetBytes,
            deviceMaxBufferBytes:
                deviceMaxBufferBytes,
            batchSize: batchSize,
            gradientAccumulationSteps:
                gradientAccumulationSteps,
            sequenceLength: sequenceLength,
            completedSteps: completedSteps,
            processedPaddedTokenPositions:
                processedPaddedTokenPositions,
            supervisedTargetTokenCount:
                supervisedTargetTokenCount,
            mechanicsActiveElapsedSeconds:
                mechanicsActiveElapsedSeconds,
            peakActiveMemoryBytes:
                peakActiveMemoryBytes,
            mechanics: mechanics,
            boundary: boundary,
            supervisorAttestation:
                supervisorAttestation,
            stopReason: stopReason,
            functionalAutoregressiveOutputCount:
                functionalAutoregressiveOutputCount,
            longTrainingAuthorized:
                longTrainingAuthorized,
            nextAction: nextAction
        )
    }

    public var durableEvidence:
        PrimeExecutionReceiptEvidence
    {
        let endToEndWallSeconds:
            PrimeObservation<Double>
        if let supervisorAttestation {
            endToEndWallSeconds = .observed(
                supervisorAttestation
                    .supervisorEndToEndWallSeconds
            )
        } else {
            endToEndWallSeconds = .unavailable
        }
        return PrimeExecutionReceiptEvidence(
            profile: profile,
            precision: precision,
            seeds: seeds,
            artifacts: artifacts,
            stopReason: stopReason,
            gpu: PrimeGPUObservations(
                deviceName: .observed(deviceDescription),
                metalExecution: .observed(true)
            ),
            memory: PrimeMemoryObservations(
                peakActiveBytes:
                    .observed(peakActiveMemoryBytes),
                peakCacheBytes: .unavailable
            ),
            timing: PrimeTimingObservations(
                endToEndWallSeconds:
                    endToEndWallSeconds,
                processedPaddedPositionsPerSecond:
                    .observed(
                    Double(
                        processedPaddedTokenPositions
                    ) / mechanicsActiveElapsedSeconds
                ),
                processedPaddedPositions: .observed(
                    processedPaddedTokenPositions
                ),
                supervisedTargetTokens: .observed(
                    supervisedTargetTokenCount
                )
            ),
            pythonExecution: boundary.pythonExecution,
            shellScientificAuthority:
                boundary.shellScientificAuthority,
            externalExecutionExclusionReason:
                boundary.externalExecutionExclusionReason
        )
    }

    public func durableReceipt(
        receiptID: String
    ) -> PrimeCalibrationReceipt {
        PrimeCalibrationReceipt(
            receiptID: receiptID,
            recordedAtUTC: recordedAtUTC,
            verdict:
                outcome == .grounded
                    ? .feasible
                    : .abstain,
            evidence: durableEvidence
        )
    }
}

public enum PrimeGPUCalibrationFailureStage:
    String,
    Codable,
    Sendable
{
    case supervisorLaunch = "supervisor_launch"
    case metalLeaseAcquisition =
        "metal_lease_acquisition"
    case workerPreflight = "worker_preflight"
    case modelAllocation = "model_allocation"
    case forwardBackwardUpdate =
        "forward_backward_update"
    case metallibReverification =
        "metallib_reverification"
    case receiptValidation = "receipt_validation"
    case workerTermination = "worker_termination"
}

public enum PrimeGPUCalibrationFailureReason:
    String,
    Codable,
    Sendable
{
    case outOfMemory = "out_of_memory"
    case timeLimitObserved =
        "time_limit_observed"
    case nonFinite = "non_finite"
    case contractViolation = "contract_violation"
    case executorFailure = "executor_failure"

    fileprivate var stopReason: PrimeReceiptStopReason {
        switch self {
        case .outOfMemory:
            .outOfMemory
        case .timeLimitObserved:
            .timeLimitReached
        case .nonFinite:
            .nonFiniteLoss
        case .contractViolation, .executorFailure:
            .executorFailure
        }
    }
}

public enum PrimeGPUCalibrationElapsedTimeScope:
    String,
    Codable,
    Sendable
{
    case workerExecution = "worker_execution"
    case supervisorEndToEnd = "supervisor_end_to_end"
}

/// A distinct ABSTAIN receipt for costly Metal attempts that cannot satisfy
/// the grounded mechanics contract. It never fabricates successful mechanics.
public struct PrimeGPUCalibrationFailureReceipt:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let outcome: PrimeGPUCalibrationOutcome
    public let recordedAtUTC: String
    public let claimScope: String
    public let profile: PrimeNativeModelProfile
    public let seeds: PrimeExecutionSeeds
    public let artifacts: PrimeExecutionArtifactBindings
    public let stage: PrimeGPUCalibrationFailureStage
    public let reason: PrimeGPUCalibrationFailureReason
    public let detail: String
    public let elapsedSeconds:
        PrimeObservation<Double>
    public let elapsedTimeScope:
        PrimeGPUCalibrationElapsedTimeScope
    public let peakActiveMemoryBytes:
        PrimeObservation<UInt64>
    public let deviceArchitecture:
        PrimeObservation<String>
    public let deviceDescription:
        PrimeObservation<String>
    public let metalExecutionBegan:
        PrimeBooleanObservation
    public let boundary: PrimeGPUCalibrationBoundary
    public let functionalAutoregressiveOutputCount: Int
    public let longTrainingAuthorized: Bool
    public let nextAction: String

    public init(
        schemaVersion: Int = 2,
        recordedAtUTC: String,
        claimScope: String,
        profile: PrimeNativeModelProfile =
            PrimeNativeProfiles.exact3B,
        seeds: PrimeExecutionSeeds,
        artifacts: PrimeExecutionArtifactBindings,
        stage: PrimeGPUCalibrationFailureStage,
        reason: PrimeGPUCalibrationFailureReason,
        detail: String,
        elapsedSeconds:
            PrimeObservation<Double>,
        elapsedTimeScope:
            PrimeGPUCalibrationElapsedTimeScope,
        peakActiveMemoryBytes:
            PrimeObservation<UInt64>,
        deviceArchitecture:
            PrimeObservation<String>,
        deviceDescription:
            PrimeObservation<String>,
        metalExecutionBegan:
            PrimeBooleanObservation,
        boundary: PrimeGPUCalibrationBoundary,
        functionalAutoregressiveOutputCount: Int = 0,
        longTrainingAuthorized: Bool = false,
        nextAction: String
    ) {
        self.schemaVersion = schemaVersion
        artifactKind =
            "ergentics_prime_3b_fp32_gpu_calibration_failure_v2"
        outcome = .abstain
        self.recordedAtUTC = recordedAtUTC
        self.claimScope = claimScope
        self.profile = profile
        self.seeds = seeds
        self.artifacts = artifacts
        self.stage = stage
        self.reason = reason
        self.detail = detail
        self.elapsedSeconds = elapsedSeconds
        self.elapsedTimeScope = elapsedTimeScope
        self.peakActiveMemoryBytes =
            peakActiveMemoryBytes
        self.deviceArchitecture =
            deviceArchitecture
        self.deviceDescription = deviceDescription
        self.metalExecutionBegan =
            metalExecutionBegan
        self.boundary = boundary
        self.functionalAutoregressiveOutputCount =
            functionalAutoregressiveOutputCount
        self.longTrainingAuthorized =
            longTrainingAuthorized
        self.nextAction = nextAction
    }

    public func validate(
        in root: PrimeArtifactRoot
    ) throws {
        guard schemaVersion == 2,
              artifactKind
                == "ergentics_prime_3b_fp32_gpu_calibration_failure_v2",
              outcome == .abstain,
              profile == PrimeNativeProfiles.exact3B,
              !recordedAtUTC.isEmpty,
              !claimScope.isEmpty,
              !detail.isEmpty,
              functionalAutoregressiveOutputCount == 0,
              !longTrainingAuthorized,
              !nextAction.isEmpty else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "invalid exact-3B FP32 GPU failure receipt"
            )
        }
        try elapsedSeconds.validate(
            "failed calibration elapsed seconds"
        )
        try peakActiveMemoryBytes.validate(
            "failed calibration peak active memory"
        )
        try deviceArchitecture.validate(
            "failed calibration device architecture"
        )
        try deviceDescription.validate(
            "failed calibration device description"
        )
        try metalExecutionBegan.validate(
            "failed calibration Metal execution"
        )
        if let elapsed = elapsedSeconds.value,
           !elapsed.isFinite || elapsed <= 0 {
            throw PrimeDurableArtifactError.invalidObservation(
                "observed failed calibration elapsed time must be finite and positive"
            )
        }
        let configuration = try root.decodeVerified(
            PrimeNative3BFP32ExecutionConfiguration.self,
            binding: artifacts.configuration
        )
        try configuration.validate()
        if reason == .timeLimitObserved {
            guard let elapsed = elapsedSeconds.value else {
                throw PrimeDurableArtifactError.invalidObservation(
                    "time-limit failure requires an observed elapsed duration"
                )
            }
            let threshold: Double
            switch elapsedTimeScope {
            case .workerExecution:
                threshold = configuration.calibrationPlan
                    .workerActiveTimeLimitSeconds
            case .supervisorEndToEnd:
                threshold = configuration.calibrationPlan
                    .supervisorEndToEndWallLimitSeconds
            }
            guard elapsed >= threshold else {
                throw PrimeDurableArtifactError.invalidObservation(
                    "time-limit failure elapsed duration is below its declared scope limit"
                )
            }
        }
        if let peak = peakActiveMemoryBytes.value,
           peak == 0 {
            throw PrimeDurableArtifactError.invalidObservation(
                "observed failed calibration peak active memory must be positive"
            )
        }
        try boundary.validate()
        let evidence = durableEvidence
        try evidence.validateDeclarations()
        try PrimeReceiptAuthorization.validateEvidence(
            evidence,
            in: root
        )
    }

    public var durableEvidence:
        PrimeExecutionReceiptEvidence
    {
        let endToEndWallSeconds:
            PrimeObservation<Double>
        switch elapsedTimeScope {
        case .workerExecution:
            endToEndWallSeconds = .unavailable
        case .supervisorEndToEnd:
            endToEndWallSeconds = elapsedSeconds
        }
        return PrimeExecutionReceiptEvidence(
            profile: profile,
            precision: .float32,
            seeds: seeds,
            artifacts: artifacts,
            stopReason: reason.stopReason,
            gpu: PrimeGPUObservations(
                deviceName:
                    deviceArchitecture
                        .observationAvailable
                        ? deviceArchitecture
                        : deviceDescription,
                metalExecution: metalExecutionBegan
            ),
            memory: PrimeMemoryObservations(
                peakActiveBytes:
                    peakActiveMemoryBytes,
                peakCacheBytes: .unavailable
            ),
            timing: PrimeTimingObservations(
                endToEndWallSeconds:
                    endToEndWallSeconds,
                processedPaddedPositionsPerSecond:
                    .unavailable,
                processedPaddedPositions:
                    .unavailable,
                supervisedTargetTokens:
                    .unavailable
            ),
            pythonExecution: boundary.pythonExecution,
            shellScientificAuthority:
                boundary.shellScientificAuthority,
            externalExecutionExclusionReason:
                boundary.externalExecutionExclusionReason
        )
    }
}

public struct PrimeGPUObservations:
    Codable,
    Equatable,
    Sendable
{
    public let deviceName: PrimeObservation<String>
    public let metalExecution:
        PrimeBooleanObservation

    public init(
        deviceName: PrimeObservation<String>,
        metalExecution: PrimeBooleanObservation
    ) {
        self.deviceName = deviceName
        self.metalExecution = metalExecution
    }

    fileprivate func validate() throws {
        try deviceName.validate("GPU device name")
        try metalExecution.validate("Metal GPU execution")
        if let name = deviceName.value,
           name.trimmingCharacters(
               in: .whitespacesAndNewlines
           ).isEmpty {
            throw PrimeDurableArtifactError.invalidObservation(
                "an observed GPU device name cannot be empty"
            )
        }
    }
}

public struct PrimeMemoryObservations:
    Codable,
    Equatable,
    Sendable
{
    public let peakActiveBytes: PrimeObservation<UInt64>
    public let peakCacheBytes: PrimeObservation<UInt64>

    public init(
        peakActiveBytes: PrimeObservation<UInt64>,
        peakCacheBytes: PrimeObservation<UInt64>
    ) {
        self.peakActiveBytes = peakActiveBytes
        self.peakCacheBytes = peakCacheBytes
    }

    fileprivate func validate() throws {
        try peakActiveBytes.validate("peak active memory")
        try peakCacheBytes.validate("peak cache memory")
        if let value = peakActiveBytes.value, value == 0 {
            throw PrimeDurableArtifactError.invalidObservation(
                "observed peak active memory must be positive"
            )
        }
    }
}

public struct PrimeTimingObservations:
    Codable,
    Equatable,
    Sendable
{
    public let endToEndWallSeconds:
        PrimeObservation<Double>
    public let processedPaddedPositionsPerSecond:
        PrimeObservation<Double>
    public let processedPaddedPositions:
        PrimeObservation<UInt64>
    public let supervisedTargetTokens:
        PrimeObservation<UInt64>

    public init(
        endToEndWallSeconds: PrimeObservation<Double>,
        processedPaddedPositionsPerSecond:
            PrimeObservation<Double>,
        processedPaddedPositions:
            PrimeObservation<UInt64>,
        supervisedTargetTokens:
            PrimeObservation<UInt64>
    ) {
        self.endToEndWallSeconds =
            endToEndWallSeconds
        self.processedPaddedPositionsPerSecond =
            processedPaddedPositionsPerSecond
        self.processedPaddedPositions =
            processedPaddedPositions
        self.supervisedTargetTokens =
            supervisedTargetTokens
    }

    fileprivate func validate() throws {
        try endToEndWallSeconds.validate(
            "end-to-end wall seconds"
        )
        try processedPaddedPositionsPerSecond.validate(
            "processed padded positions per second"
        )
        try processedPaddedPositions.validate(
            "processed padded positions"
        )
        try supervisedTargetTokens.validate(
            "supervised target tokens"
        )
        if let value = endToEndWallSeconds.value,
           !value.isFinite || value <= 0 {
            throw PrimeDurableArtifactError.invalidObservation(
                "observed end-to-end wall time must be finite and positive"
            )
        }
        if let value =
                processedPaddedPositionsPerSecond.value,
           !value.isFinite || value <= 0 {
            throw PrimeDurableArtifactError.invalidObservation(
                "observed padded-position rate must be finite and positive"
            )
        }
        if let value = processedPaddedPositions.value,
           value == 0 {
            throw PrimeDurableArtifactError.invalidObservation(
                "observed padded-position count must be positive"
            )
        }
        if let value = supervisedTargetTokens.value,
           value == 0 {
            throw PrimeDurableArtifactError.invalidObservation(
                "observed supervised-target count must be positive"
            )
        }
    }
}

public struct PrimeExecutionReceiptEvidence:
    Codable,
    Equatable,
    Sendable
{
    public let profile: PrimeNativeModelProfile
    public let precision: PrimeNumericPrecision
    public let seeds: PrimeExecutionSeeds
    public let artifacts: PrimeExecutionArtifactBindings
    public let stopReason: PrimeReceiptStopReason
    public let gpu: PrimeGPUObservations
    public let memory: PrimeMemoryObservations
    public let timing: PrimeTimingObservations
    public let pythonExecution: PrimeBooleanObservation
    public let shellScientificAuthority:
        PrimeBooleanObservation
    public let externalExecutionExclusionReason: String

    public init(
        profile: PrimeNativeModelProfile =
            PrimeNativeProfiles.exact3B,
        precision: PrimeNumericPrecision = .float32,
        seeds: PrimeExecutionSeeds,
        artifacts: PrimeExecutionArtifactBindings,
        stopReason: PrimeReceiptStopReason,
        gpu: PrimeGPUObservations,
        memory: PrimeMemoryObservations,
        timing: PrimeTimingObservations,
        pythonExecution: PrimeBooleanObservation,
        shellScientificAuthority:
            PrimeBooleanObservation,
        externalExecutionExclusionReason: String
    ) {
        self.profile = profile
        self.precision = precision
        self.seeds = seeds
        self.artifacts = artifacts
        self.stopReason = stopReason
        self.gpu = gpu
        self.memory = memory
        self.timing = timing
        self.pythonExecution = pythonExecution
        self.shellScientificAuthority =
            shellScientificAuthority
        self.externalExecutionExclusionReason =
            externalExecutionExclusionReason
    }

    fileprivate func validateDeclarations() throws {
        guard profile == PrimeNativeProfiles.exact3B,
              precision == .float32 else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "receipt must bind the frozen native 3B FP32 profile"
            )
        }
        try validateReceiptSeeds(seeds)
        try artifacts.executable.validateDeclaration()
        try artifacts.configuration.validateDeclaration()
        try artifacts.sourceSnapshot.validateDeclaration()
        try artifacts.mlxDefaultMetallib
            .validateDeclaration()
        guard artifacts.executable.purpose == .executable,
              artifacts.configuration.purpose
                == .immutableData,
              artifacts.sourceSnapshot.purpose
                == .immutableData,
              artifacts.mlxDefaultMetallib
                .artifact.purpose
                == .immutableData,
              artifacts.mlxDefaultMetallib
                .infoPlistArtifact.purpose
                == .immutableData else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "receipt artifact purposes are invalid"
            )
        }
        try gpu.validate()
        try memory.validate()
        try timing.validate()
        try pythonExecution.validate("Python execution")
        try shellScientificAuthority.validate(
            "shell scientific authority"
        )
        guard pythonExecution.observationAvailable,
              pythonExecution.value == false,
              shellScientificAuthority
                .observationAvailable,
              shellScientificAuthority.value == false else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "receipt must explicitly observe Python execution=false and shell scientific authority=false"
            )
        }
        guard !externalExecutionExclusionReason
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "receipt must state why Python and shell were excluded"
            )
        }
    }
}

public enum PrimeCalibrationVerdict:
    String,
    Codable,
    Sendable
{
    case feasible
    case abstain = "ABSTAIN"
    case infeasible
}

public struct PrimeCalibrationReceipt:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let receiptID: String
    public let recordedAtUTC: String
    public let verdict: PrimeCalibrationVerdict
    public let evidence: PrimeExecutionReceiptEvidence

    public init(
        schemaVersion: Int = 2,
        receiptID: String,
        recordedAtUTC: String,
        verdict: PrimeCalibrationVerdict,
        evidence: PrimeExecutionReceiptEvidence
    ) {
        self.schemaVersion = schemaVersion
        self.receiptID = receiptID
        self.recordedAtUTC = recordedAtUTC
        self.verdict = verdict
        self.evidence = evidence
    }

    public func validate(in root: PrimeArtifactRoot) throws {
        guard schemaVersion == 2,
              !receiptID.isEmpty,
              !recordedAtUTC.isEmpty else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "invalid calibration receipt identity"
            )
        }
        try evidence.validateDeclarations()
        try PrimeReceiptAuthorization.validateEvidence(
            evidence,
            in: root
        )
        if verdict == .feasible {
            guard evidence.stopReason
                    == .calibrationBudgetReached
                    || evidence.stopReason
                    == .convergenceReached
                    || evidence.stopReason
                    == .mechanicsCompleted,
                  evidence.gpu.metalExecution.value == true,
                  evidence.gpu.deviceName.value != nil,
                  evidence.memory.peakActiveBytes.value != nil,
                  evidence.timing
                    .endToEndWallSeconds.value != nil,
                  evidence.timing
                    .processedPaddedPositionsPerSecond
                    .value != nil,
                  evidence.timing
                    .processedPaddedPositions.value != nil,
                  evidence.timing
                    .supervisedTargetTokens.value != nil else {
                throw PrimeDurableArtifactError.invalidSemantics(
                    "a feasible calibration requires observed Metal, memory, timing, throughput, and trained-token evidence"
                )
            }
        }
    }
}

public struct PrimeRunReceipt:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let receiptID: String
    public let recordedAtUTC: String
    public let calibrationReceipt: PrimeArtifactBinding
    public let evidence: PrimeExecutionReceiptEvidence

    public init(
        schemaVersion: Int = 2,
        receiptID: String,
        recordedAtUTC: String,
        calibrationReceipt: PrimeArtifactBinding,
        evidence: PrimeExecutionReceiptEvidence
    ) {
        self.schemaVersion = schemaVersion
        self.receiptID = receiptID
        self.recordedAtUTC = recordedAtUTC
        self.calibrationReceipt = calibrationReceipt
        self.evidence = evidence
    }

    public func validate(in root: PrimeArtifactRoot) throws {
        guard schemaVersion == 2,
              !receiptID.isEmpty,
              !recordedAtUTC.isEmpty,
              calibrationReceipt.purpose == .immutableData else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "invalid run receipt identity or calibration binding"
            )
        }
        try evidence.validateDeclarations()
        try PrimeReceiptAuthorization.validateEvidence(
            evidence,
            in: root
        )
        let calibration = try root.decodeVerified(
            PrimeCalibrationReceipt.self,
            binding: calibrationReceipt
        )
        try calibration.validate(in: root)
        guard calibration.verdict == .feasible,
              calibration.evidence.profile == evidence.profile,
              calibration.evidence.precision
                == evidence.precision,
              calibration.evidence.seeds == evidence.seeds,
              calibration.evidence.artifacts
                == evidence.artifacts,
              calibration.evidence.pythonExecution
                == evidence.pythonExecution,
              calibration.evidence.shellScientificAuthority
                == evidence.shellScientificAuthority,
              calibration.evidence
                .externalExecutionExclusionReason
                == evidence
                    .externalExecutionExclusionReason else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "run receipt is not backed by a matching feasible calibration"
            )
        }
    }
}

public struct PrimeRunAuthorization:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let profile: PrimeNativeModelProfile
    public let precision: PrimeNumericPrecision
    public let seeds: PrimeExecutionSeeds
    public let artifacts: PrimeExecutionArtifactBindings
    public let calibrationReceipt: PrimeArtifactBinding
    public let implementationLanguage: PrimeExecutionLanguage
    public let pythonExecutionAuthorized: Bool
    public let shellScientificAuthorityAuthorized: Bool
    public let externalExecutionExclusionReason: String

    public init(
        schemaVersion: Int = 2,
        profile: PrimeNativeModelProfile =
            PrimeNativeProfiles.exact3B,
        precision: PrimeNumericPrecision = .float32,
        seeds: PrimeExecutionSeeds,
        artifacts: PrimeExecutionArtifactBindings,
        calibrationReceipt: PrimeArtifactBinding,
        implementationLanguage: PrimeExecutionLanguage =
            .swift,
        pythonExecutionAuthorized: Bool = false,
        shellScientificAuthorityAuthorized: Bool = false,
        externalExecutionExclusionReason: String
    ) {
        self.schemaVersion = schemaVersion
        self.profile = profile
        self.precision = precision
        self.seeds = seeds
        self.artifacts = artifacts
        self.calibrationReceipt = calibrationReceipt
        self.implementationLanguage = implementationLanguage
        self.pythonExecutionAuthorized =
            pythonExecutionAuthorized
        self.shellScientificAuthorityAuthorized =
            shellScientificAuthorityAuthorized
        self.externalExecutionExclusionReason =
            externalExecutionExclusionReason
    }

    public func resolve(
        in root: PrimeArtifactRoot
    ) throws -> PrimeResolvedRunAuthorization {
        guard schemaVersion == 2,
              profile == PrimeNativeProfiles.exact3B,
              precision == .float32,
              implementationLanguage == .swift,
              !pythonExecutionAuthorized,
              !shellScientificAuthorityAuthorized,
              !externalExecutionExclusionReason
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "authorization must be exact 3B FP32, Swift-only, and explicitly exclude Python execution plus shell scientific authority"
            )
        }
        try validateReceiptSeeds(seeds)
        try root.verifySeedProvenance(
            seeds.initialization
        )
        try root.verifySeedProvenance(
            seeds.trainingSchedule
        )
        try root.verifySeedProvenance(
            seeds.evaluation
        )
        guard artifacts.executable.purpose == .executable,
              artifacts.configuration.purpose
                == .immutableData,
              artifacts.sourceSnapshot.purpose
                == .immutableData,
              artifacts.mlxDefaultMetallib
                .artifact.purpose
                == .immutableData,
              artifacts.mlxDefaultMetallib
                .infoPlistArtifact.purpose
                == .immutableData,
              calibrationReceipt.purpose
                == .immutableData else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "authorization artifact purposes are invalid"
            )
        }

        let executable = try root.verify(
            artifacts.executable
        )
        let source = try PrimeReceiptAuthorization
            .verifyReleaseSourceSnapshot(
                artifacts.sourceSnapshot,
                in: root
            )
        let metallib = try root.verify(
            artifacts.mlxDefaultMetallib.artifact
        )
        let metallibInfoPlist = try root.verify(
            artifacts.mlxDefaultMetallib
                .infoPlistArtifact
        )
        let configuration:
            PrimeNative3BFP32ExecutionConfiguration =
                try root.decodeVerified(
                    PrimeNative3BFP32ExecutionConfiguration.self,
                    binding: artifacts.configuration
                )
        try configuration.validate()
        guard configuration.profile == profile,
              configuration.precision == precision,
              configuration.seeds == seeds,
              configuration.executable
                == artifacts.executable,
              configuration.sourceSnapshot
                == artifacts.sourceSnapshot,
              configuration.mlxDefaultMetallib
                == artifacts.mlxDefaultMetallib,
              configuration.pythonExecutionAuthorized
                == pythonExecutionAuthorized,
              configuration
                .shellScientificAuthorityAuthorized
                == shellScientificAuthorityAuthorized,
              configuration.externalExecutionExclusionReason
                == externalExecutionExclusionReason else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "resolved configuration does not match the requested authorization"
            )
        }

        let configurationArtifact = try root.verify(
            artifacts.configuration
        )
        let calibration:
            PrimeCalibrationReceipt =
                try root.decodeVerified(
                    PrimeCalibrationReceipt.self,
                    binding: calibrationReceipt
                )
        try calibration.validate(in: root)
        guard calibration.verdict == .feasible,
              calibration.evidence.profile == profile,
              calibration.evidence.precision == precision,
              calibration.evidence.seeds == seeds,
              calibration.evidence.artifacts == artifacts,
              calibration.evidence.pythonExecution
                == .observed(pythonExecutionAuthorized),
              calibration.evidence.shellScientificAuthority
                == .observed(
                    shellScientificAuthorityAuthorized
                ),
              calibration.evidence
                .externalExecutionExclusionReason
                == externalExecutionExclusionReason else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "authorization lacks a matching feasible calibration"
            )
        }
        let calibrationArtifact = try root.verify(
            calibrationReceipt
        )

        return PrimeResolvedRunAuthorization(
            authorization: self,
            executable: executable,
            configuration: configurationArtifact,
            sourceSnapshot: source,
            mlxDefaultMetallib: metallib,
            mlxBundleInfoPlist:
                metallibInfoPlist,
            calibrationReceipt: calibrationArtifact
        )
    }
}

public struct PrimeResolvedRunAuthorization:
    Equatable,
    Sendable
{
    public let authorization: PrimeRunAuthorization
    public let executable: PrimeVerifiedArtifact
    public let configuration: PrimeVerifiedArtifact
    public let sourceSnapshot: PrimeVerifiedArtifact
    public let mlxDefaultMetallib: PrimeVerifiedArtifact
    public let mlxBundleInfoPlist: PrimeVerifiedArtifact
    public let calibrationReceipt: PrimeVerifiedArtifact
}

private enum PrimeReceiptAuthorization {
    static func verifyReleaseSourceSnapshot(
        _ binding: PrimeArtifactBinding,
        in root: PrimeArtifactRoot
    ) throws -> PrimeVerifiedArtifact {
        let verified = try root.verify(binding)
        let snapshot = try root.decodeVerified(
            PrimeSwiftSourceSnapshot.self,
            binding: binding,
            maximumByteCount: 64 * 1024 * 1024
        )
        try PrimeSwiftSourceProvenance
            .validateReleaseEvidence(
                snapshot,
                requiredRelativePaths:
                    PrimeNative3BFP32ExecutionConfiguration
                    .requiredPrimeSourceRelativePaths
            )
        return verified
    }

    static func validateEvidence(
        _ evidence: PrimeExecutionReceiptEvidence,
        in root: PrimeArtifactRoot
    ) throws {
        try root.verifySeedProvenance(
            evidence.seeds.initialization
        )
        try root.verifySeedProvenance(
            evidence.seeds.trainingSchedule
        )
        try root.verifySeedProvenance(
            evidence.seeds.evaluation
        )
        let configuration:
            PrimeNative3BFP32ExecutionConfiguration =
                try root.decodeVerified(
                    PrimeNative3BFP32ExecutionConfiguration.self,
                    binding: evidence.artifacts.configuration
                )
        try configuration.validate()
        guard configuration.profile == evidence.profile,
              configuration.precision == evidence.precision,
              configuration.seeds == evidence.seeds,
              configuration.executable
                == evidence.artifacts.executable,
              configuration.sourceSnapshot
                == evidence.artifacts.sourceSnapshot,
              configuration.mlxDefaultMetallib
                == evidence.artifacts
                    .mlxDefaultMetallib,
              configuration.pythonExecutionAuthorized == false,
              configuration
                .shellScientificAuthorityAuthorized == false,
              configuration.externalExecutionExclusionReason
                == evidence.externalExecutionExclusionReason else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "receipt evidence does not match its resolved configuration"
            )
        }
        _ = try root.verify(evidence.artifacts.executable)
        _ = try root.verify(evidence.artifacts.configuration)
        _ = try verifyReleaseSourceSnapshot(
            evidence.artifacts.sourceSnapshot,
            in: root
        )
        _ = try root.verify(
            evidence.artifacts.mlxDefaultMetallib
                .artifact
        )
        _ = try root.verify(
            evidence.artifacts.mlxDefaultMetallib
                .infoPlistArtifact
        )
    }
}
