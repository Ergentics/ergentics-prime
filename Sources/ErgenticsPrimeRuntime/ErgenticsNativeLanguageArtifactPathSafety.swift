#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation

/// POSIX path checks and descriptor-anchored publication for
/// native-language evidence.
///
/// Foundation existence checks follow links and report a dangling symlink as
/// absent. Evidence paths must instead treat every symlink as an existing,
/// invalid entry so atomic writes cannot replace it or create its target.
///
/// This is not an isolation boundary against malicious code running under the
/// same effective user ID. Such code can mutate any user-owned path before or
/// after publication. A detected same-user source substitution may leave a
/// divergent canonical entry that every later invocation refuses; it is never
/// accepted as evidence. Other identities are excluded through descriptor
/// ownership, POSIX mode, and extended-ACL checks.
public enum ErgenticsNativeLanguageArtifactPathSafety {
    public enum EntryKind: Equatable, Sendable {
        case regularFile
        case directory
        case symbolicLink
        case other
    }

    private static func posixError(
        _ operation: String,
        path: String,
        code: Int32 = errno
    ) -> NSError {
        NSError(
            domain: NSPOSIXErrorDomain,
            code: Int(code),
            userInfo: [
                NSLocalizedDescriptionKey:
                    "\(operation) failed for \(path): "
                    + String(cString: strerror(code)),
            ]
        )
    }

    /// Synchronizes descriptor-visible state and, on Darwin, requests the
    /// stronger device flush required for the power-loss durability claim.
    private static func synchronize(
        _ descriptor: Int32,
        operation: String,
        path: String
    ) throws {
        guard fsync(descriptor) == 0 else {
            throw posixError(operation, path: path)
        }
        #if canImport(Darwin)
        guard fcntl(descriptor, F_FULLFSYNC) == 0 else {
            throw posixError(
                "\(operation) F_FULLFSYNC",
                path: path
            )
        }
        #endif
    }

    public static func entryKind(
        at url: URL
    ) throws -> EntryKind? {
        var metadata = stat()
        let status = url.path.withCString {
            lstat($0, &metadata)
        }
        if status != 0 {
            if errno == ENOENT { return nil }
            throw posixError("lstat", path: url.path)
        }
        switch metadata.st_mode & mode_t(S_IFMT) {
        case mode_t(S_IFREG):
            return .regularFile
        case mode_t(S_IFDIR):
            return .directory
        case mode_t(S_IFLNK):
            return .symbolicLink
        default:
            return .other
        }
    }

    /// Lexically normalizes an absolute path without asking Foundation to
    /// resolve filesystem aliases. `standardizedFileURL` rewrites an existing
    /// `/private/tmp/...` path to `/tmp/...` on macOS; that would manufacture
    /// a symlink ancestor that the caller did not provide.
    private static func lexicalAbsoluteComponents(
        _ url: URL
    ) throws -> [String] {
        let path = url.path
        guard path.hasPrefix("/") else {
            throw NSError(
                domain: "ErgenticsNativeLanguageArtifactPathSafety",
                code: 9,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "artifact path is not absolute: \(path)",
                ]
            )
        }
        var result = [String]()
        for component in path.split(
            separator: "/",
            omittingEmptySubsequences: true
        ).map(String.init) {
            if component == "." { continue }
            if component == ".." {
                if !result.isEmpty {
                    result.removeLast()
                }
                continue
            }
            result.append(component)
        }
        return result
    }

    private static func absoluteURL(
        components: ArraySlice<String>
    ) -> URL {
        URL(
            fileURLWithPath:
                "/" + components.joined(separator: "/"),
            isDirectory: true
        )
    }

    private static func publicationComponents(
        _ url: URL,
        label: String
    ) throws -> (parents: ArraySlice<String>, leaf: String) {
        let path = url.path
        guard url.isFileURL,
              path.hasPrefix("/"),
              path != "/",
              !path.utf8.contains(0) else {
            throw NSError(
                domain: "ErgenticsNativeLanguageArtifactPathSafety",
                code: 9,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "\(label) publication path is not a safe "
                        + "absolute file path: \(path)",
                ]
            )
        }
        let rawComponents = path.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
        guard rawComponents.first?.isEmpty == true else {
            throw NSError(
                domain: "ErgenticsNativeLanguageArtifactPathSafety",
                code: 9,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "\(label) publication path is not absolute: "
                        + path,
                ]
            )
        }
        let components = rawComponents.dropFirst().map(String.init)
        guard !components.isEmpty,
              components.allSatisfy({
                  !$0.isEmpty
                      && $0 != "."
                      && $0 != ".."
                      && !$0.utf8.contains(0)
                      && !$0.contains("/")
                      && $0.utf8.count <= 255
              }),
              let leaf = components.last else {
            throw NSError(
                domain: "ErgenticsNativeLanguageArtifactPathSafety",
                code: 9,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "\(label) publication path contains an "
                        + "unsafe component: \(path)",
                ]
            )
        }
        return (components.dropLast(), leaf)
    }

    private static func withAnchoredParentDirectory<Result>(
        components: ArraySlice<String>,
        label: String,
        createMissingDirectories: Bool = true,
        _ operation: (Int32) throws -> Result
    ) throws -> Result {
        let directoryFlags =
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        var descriptor = open("/", directoryFlags)
        guard descriptor >= 0 else {
            throw posixError("open", path: "/")
        }
        defer {
            if descriptor >= 0 {
                _ = close(descriptor)
            }
        }
        try requireTrustedPublicationDirectory(
            descriptor: descriptor,
            path: "/",
            label: label
        )

        var traversed = [String]()
        for component in components {
            traversed.append(component)
            let componentPath =
                "/" + traversed.joined(separator: "/")
            var childDescriptor = component.withCString {
                openat(descriptor, $0, directoryFlags)
            }
            if childDescriptor < 0,
               errno == ENOENT,
               createMissingDirectories {
                let makeStatus = component.withCString {
                    mkdirat(descriptor, $0, 0o755)
                }
                let makeError = errno
                guard makeStatus == 0 || makeError == EEXIST else {
                    throw posixError(
                        "mkdirat",
                        path: componentPath,
                        code: makeError
                    )
                }
                try synchronize(
                    descriptor,
                    operation: "synchronize parent directory",
                    path: componentPath
                )
                childDescriptor = component.withCString {
                    openat(descriptor, $0, directoryFlags)
                }
            }
            guard childDescriptor >= 0 else {
                throw posixError(
                    "openat directory",
                    path: componentPath
                )
            }
            do {
                try requireTrustedPublicationDirectory(
                    descriptor: childDescriptor,
                    path: componentPath,
                    label: label
                )
            } catch {
                _ = close(childDescriptor)
                throw error
            }
            let priorDescriptor = descriptor
            descriptor = childDescriptor
            _ = close(priorDescriptor)
        }
        return try operation(descriptor)
    }

    private static func refusalError(
        label: String,
        path: String,
        detail: String
    ) -> NSError {
        NSError(
            domain: "ErgenticsNativeLanguageArtifactPathSafety",
            code: 8,
            userInfo: [
                NSLocalizedDescriptionKey:
                    "refusing to publish \(label) at \(path): "
                    + detail,
            ]
        )
    }

    private static func requireNoExtendedACL(
        descriptor: Int32,
        path: String,
        label: String
    ) throws {
        #if canImport(Darwin)
        errno = 0
        guard let acl = acl_get_fd_np(
            descriptor,
            ACL_TYPE_EXTENDED
        ) else {
            let code = errno
            if code == ENOENT { return }
            throw posixError(
                "acl_get_fd_np",
                path: path,
                code: code
            )
        }
        defer {
            _ = acl_free(UnsafeMutableRawPointer(acl))
        }
        throw refusalError(
            label: label,
            path: path,
            detail:
                "an extended ACL makes ownership and POSIX mode "
                + "insufficient publication authority"
        )
        #endif
    }

    /// Publication parents may carry deny-only ACLs installed by macOS (for
    /// example the user's home and Documents directories). They must not carry
    /// an extended allow entry with mutation authority.
    private static func requireNoWritableExtendedACL(
        descriptor: Int32,
        path: String,
        label: String
    ) throws {
        #if canImport(Darwin)
        errno = 0
        guard let acl = acl_get_fd_np(
            descriptor,
            ACL_TYPE_EXTENDED
        ) else {
            let code = errno
            if code == ENOENT { return }
            throw posixError(
                "acl_get_fd_np",
                path: path,
                code: code
            )
        }
        defer {
            _ = acl_free(UnsafeMutableRawPointer(acl))
        }

        var entry: acl_entry_t?
        var entryID = Int32(ACL_FIRST_ENTRY.rawValue)
        while true {
            errno = 0
            let entryStatus =
                acl_get_entry(acl, entryID, &entry)
            if entryStatus != 0 {
                // Darwin reports the end of an already-started extended ACL
                // iteration as EINVAL for ACL_NEXT_ENTRY.
                if entryID
                        == Int32(ACL_NEXT_ENTRY.rawValue),
                   errno == EINVAL {
                    break
                }
                throw posixError(
                    "acl_get_entry",
                    path: path
                )
            }
            entryID = Int32(ACL_NEXT_ENTRY.rawValue)
            guard let entry else {
                throw refusalError(
                    label: label,
                    path: path,
                    detail:
                        "an extended ACL entry could not be inspected"
                )
            }
            var tag = acl_tag_t(0)
            guard acl_get_tag_type(entry, &tag) == 0 else {
                throw posixError(
                    "acl_get_tag_type",
                    path: path
                )
            }
            guard tag == ACL_EXTENDED_ALLOW else {
                continue
            }
            var permissions: acl_permset_t?
            guard acl_get_permset(entry, &permissions) == 0,
                  let permissions else {
                throw posixError(
                    "acl_get_permset",
                    path: path
                )
            }
            let mutatingPermissions: [acl_perm_t] = [
                ACL_WRITE_DATA,
                ACL_APPEND_DATA,
                ACL_DELETE,
                ACL_DELETE_CHILD,
                ACL_WRITE_ATTRIBUTES,
                ACL_WRITE_EXTATTRIBUTES,
                ACL_WRITE_SECURITY,
                ACL_CHANGE_OWNER,
            ]
            var grantsMutation = false
            for permission in mutatingPermissions {
                let permissionStatus =
                    acl_get_perm_np(permissions, permission)
                guard permissionStatus >= 0 else {
                    throw posixError(
                        "acl_get_perm_np",
                        path: path
                    )
                }
                if permissionStatus == 1 {
                    grantsMutation = true
                    break
                }
            }
            if grantsMutation {
                throw refusalError(
                    label: label,
                    path: path,
                    detail:
                        "an extended allow ACL grants mutation authority"
                )
            }
        }
        #endif
    }

    private static func requireTrustedPublicationDirectory(
        descriptor: Int32,
        path: String,
        label: String
    ) throws {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0 else {
            throw posixError(
                "fstat publication directory",
                path: path
            )
        }
        let mode = metadata.st_mode
        let ownerTrusted =
            metadata.st_uid == geteuid()
            || metadata.st_uid == 0
        let groupOrWorldWritable =
            mode & mode_t(S_IWGRP | S_IWOTH) != 0
        let trustedRootStickyDirectory =
            metadata.st_uid == 0
            && mode & mode_t(S_ISVTX) != 0
        guard mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              ownerTrusted,
              !groupOrWorldWritable
                || trustedRootStickyDirectory else {
            throw refusalError(
                label: label,
                path: path,
                detail:
                    "publication parent is not a trusted, non-writable "
                    + "directory"
            )
        }
        try requireNoWritableExtendedACL(
            descriptor: descriptor,
            path: path,
            label: label
        )
    }

    /// Reads an existing output through an anchored descriptor. The final
    /// directory entry must still name the same single-link regular inode
    /// after the read; pathname replacement is never accepted as idempotence.
    private static func verifyExistingData(
        _ data: Data,
        parentDescriptor: Int32,
        leaf: String,
        path: String,
        label: String
    ) throws -> Bool {
        let readFlags =
            O_RDWR | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC
        let descriptor = leaf.withCString {
            openat(parentDescriptor, $0, readFlags)
        }
        if descriptor < 0 {
            let code = errno
            if code == ENOENT { return false }
            let reason = String(cString: strerror(code))
            throw refusalError(
                label: label,
                path: path,
                detail:
                    "the existing entry could not be opened without "
                    + "following a link (\(reason))"
            )
        }
        defer { _ = close(descriptor) }

        var before = stat()
        guard fstat(descriptor, &before) == 0 else {
            throw posixError(
                "fstat existing output",
                path: path
            )
        }
        guard before.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              before.st_nlink == 1,
              before.st_uid == geteuid(),
              before.st_mode & mode_t(0o022) == 0,
              before.st_size >= 0,
              UInt64(before.st_size) == UInt64(data.count) else {
            throw refusalError(
                label: label,
                path: path,
                detail:
                    "the existing entry is linked, non-regular, "
                    + "writable by another identity, or has "
                + "divergent bytes"
            )
        }
        try requireNoExtendedACL(
            descriptor: descriptor,
            path: path,
            label: label
        )

        var offset = 0
        var buffer = [UInt8](repeating: 0, count: 65_536)
        while offset < data.count {
            let requested = min(buffer.count, data.count - offset)
            let count = buffer.withUnsafeMutableBytes { bytes in
                read(descriptor, bytes.baseAddress, requested)
            }
            if count < 0, errno == EINTR { continue }
            guard count > 0 else {
                throw refusalError(
                    label: label,
                    path: path,
                    detail: "the existing bytes changed while read"
                )
            }
            let equal = data.withUnsafeBytes { expected in
                buffer.withUnsafeBytes { observed in
                    memcmp(
                        expected.baseAddress!.advanced(by: offset),
                        observed.baseAddress!,
                        count
                    ) == 0
                }
            }
            guard equal else {
                throw refusalError(
                    label: label,
                    path: path,
                    detail: "the existing bytes diverge"
                )
            }
            offset += count
        }

        var trailingByte: UInt8 = 0
        var trailingCount: Int
        repeat {
            trailingCount = withUnsafeMutablePointer(
                to: &trailingByte
            ) {
                read(descriptor, $0, 1)
            }
        } while trailingCount < 0 && errno == EINTR
        guard trailingCount == 0 else {
            if trailingCount < 0 {
                throw posixError(
                    "read existing output",
                    path: path
                )
            }
            throw refusalError(
                label: label,
                path: path,
                detail: "the existing bytes diverge"
            )
        }

        var after = stat()
        guard fstat(descriptor, &after) == 0 else {
            throw posixError(
                "fstat existing output after read",
                path: path
            )
        }
        var boundEntry = stat()
        let bindingStatus = leaf.withCString {
            fstatat(
                parentDescriptor,
                $0,
                &boundEntry,
                AT_SYMLINK_NOFOLLOW
            )
        }
        guard bindingStatus == 0,
              after.st_dev == before.st_dev,
              after.st_ino == before.st_ino,
              after.st_size == before.st_size,
              after.st_nlink == 1,
              boundEntry.st_dev == after.st_dev,
              boundEntry.st_ino == after.st_ino,
              boundEntry.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              boundEntry.st_uid == geteuid(),
              boundEntry.st_mode & mode_t(0o022) == 0,
              boundEntry.st_nlink == 1 else {
            throw refusalError(
                label: label,
                path: path,
                detail:
                    "the existing directory binding changed while "
                    + "it was verified"
            )
        }
        try synchronize(
            descriptor,
            operation: "synchronize exact existing output",
            path: path
        )
        try synchronize(
            parentDescriptor,
            operation:
                "synchronize exact existing output parent",
            path:
                URL(fileURLWithPath: path)
                    .deletingLastPathComponent().path
        )
        return true
    }

    private static func requireSingleLinkedRegularFile(
        descriptor: Int32,
        parentDescriptor: Int32,
        name: String,
        path: String,
        label: String,
        expectedLinkCount: nlink_t
    ) throws {
        var opened = stat()
        guard fstat(descriptor, &opened) == 0 else {
            throw posixError("fstat publication file", path: path)
        }
        var bound = stat()
        let bindingStatus = name.withCString {
            fstatat(
                parentDescriptor,
                $0,
                &bound,
                AT_SYMLINK_NOFOLLOW
            )
        }
        guard bindingStatus == 0,
              opened.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              opened.st_uid == geteuid(),
              opened.st_mode & mode_t(0o022) == 0,
              opened.st_nlink == expectedLinkCount,
              bound.st_dev == opened.st_dev,
              bound.st_ino == opened.st_ino,
              bound.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              bound.st_uid == geteuid(),
              bound.st_mode & mode_t(0o022) == 0,
              bound.st_nlink == expectedLinkCount else {
            throw refusalError(
                label: label,
                path: path,
                detail:
                    "the publication inode or directory binding "
                    + "has an unexpected hard-link state"
            )
        }
        try requireNoExtendedACL(
            descriptor: descriptor,
            path: path,
            label: label
        )
    }

    /// Darwin provides the no-clobber rename primitive required to publish a
    /// file in one namespace transition. A platform without an equivalent
    /// must fail closed rather than fall back to a crash-partial link/unlink
    /// sequence.
    private static func renameNoReplace(
        sourceParentDescriptor: Int32,
        sourceName: String,
        destinationParentDescriptor: Int32,
        destinationName: String
    ) -> Int32 {
        #if canImport(Darwin)
        sourceName.withCString { source in
            destinationName.withCString { destination in
                renameatx_np(
                    sourceParentDescriptor,
                    source,
                    destinationParentDescriptor,
                    destination,
                    UInt32(RENAME_EXCL)
                )
            }
        }
        #else
        errno = ENOTSUP
        return -1
        #endif
    }

    public static func requireRegularNonSymlink(
        _ url: URL,
        label: String
    ) throws {
        try requireSafeExistingAncestors(of: url, label: label)
        guard try entryKind(at: url) == .regularFile else {
            throw NSError(
                domain: "ErgenticsNativeLanguageArtifactPathSafety",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "\(label) is not a regular non-symlink file: "
                        + url.path,
                ]
            )
        }
    }

    public static func requireDirectoryNonSymlink(
        _ url: URL,
        label: String
    ) throws {
        try requireSafeExistingAncestors(of: url, label: label)
        guard try entryKind(at: url) == .directory else {
            throw NSError(
                domain: "ErgenticsNativeLanguageArtifactPathSafety",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "\(label) is not a non-symlink directory: "
                        + url.path,
                ]
            )
        }
    }

    /// Checks every existing parent component with `lstat`. Missing suffixes
    /// are allowed; a symlink or non-directory ancestor is not.
    public static func requireSafeExistingAncestors(
        of url: URL,
        label: String
    ) throws {
        let components = try lexicalAbsoluteComponents(url)
        for end in 1 ..< max(components.count, 1) {
            let cursor = absoluteURL(
                components: components.prefix(end)
            )
            guard let kind = try entryKind(at: cursor) else {
                return
            }
            guard kind == .directory else {
                throw NSError(
                    domain:
                        "ErgenticsNativeLanguageArtifactPathSafety",
                    code: 3,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "\(label) has a symlink or non-directory "
                            + "ancestor: \(cursor.path)",
                    ]
                )
            }
        }
    }

    public static func requireAbsent(
        _ url: URL,
        label: String
    ) throws {
        try requireSafeExistingAncestors(of: url, label: label)
        guard try entryKind(at: url) == nil else {
            throw NSError(
                domain: "ErgenticsNativeLanguageArtifactPathSafety",
                code: 4,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "\(label) already exists or is a symlink: "
                        + url.path,
                ]
            )
        }
    }

    public static func requireAbsentOrRegularNonSymlink(
        _ url: URL,
        label: String
    ) throws {
        try requireSafeExistingAncestors(of: url, label: label)
        guard let kind = try entryKind(at: url) else {
            return
        }
        guard kind == .regularFile else {
            throw NSError(
                domain: "ErgenticsNativeLanguageArtifactPathSafety",
                code: 5,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "\(label) is neither absent nor a regular "
                        + "non-symlink file: \(url.path)",
                ]
            )
        }
    }

    public static func requireAbsentOrDirectoryNonSymlink(
        _ url: URL,
        label: String,
        regularFilesOnlyWhenPresent: Bool = false
    ) throws {
        try requireSafeExistingAncestors(of: url, label: label)
        guard let kind = try entryKind(at: url) else {
            return
        }
        guard kind == .directory else {
            throw NSError(
                domain: "ErgenticsNativeLanguageArtifactPathSafety",
                code: 6,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "\(label) is neither absent nor a non-symlink "
                        + "directory: \(url.path)",
                ]
            )
        }
        guard regularFilesOnlyWhenPresent else { return }
        for name in try FileManager.default.contentsOfDirectory(
            atPath: url.path
        ) {
            try requireRegularNonSymlink(
                url.appendingPathComponent(name),
                label: "\(label) entry"
            )
        }
    }

    public static func createDirectoryTreeNonSymlink(
        _ url: URL,
        label: String
    ) throws {
        let components = try lexicalAbsoluteComponents(url)
        if components.isEmpty { return }
        for end in 1 ... components.count {
            let cursor = absoluteURL(
                components: components.prefix(end)
            )
            if let kind = try entryKind(at: cursor) {
                guard kind == .directory else {
                    throw NSError(
                        domain:
                            "ErgenticsNativeLanguageArtifactPathSafety",
                        code: 7,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "\(label) has a symlink or "
                                + "non-directory component: "
                                + cursor.path,
                        ]
                    )
                }
                continue
            }
            let status = cursor.path.withCString {
                mkdir($0, 0o755)
            }
            if status != 0, errno != EEXIST {
                throw posixError("mkdir", path: cursor.path)
            }
            try requireDirectoryNonSymlink(
                cursor,
                label: label
            )
        }
    }

    /// Creates one private staging directory without replacing or following
    /// any entry. It is intended for path-only third-party writers that
    /// cannot accept an already-open output descriptor.
    public static func createPrivateDirectoryNoReplace(
        _ url: URL,
        label: String
    ) throws {
        let parsed = try publicationComponents(url, label: label)
        try withAnchoredParentDirectory(
            components: parsed.parents,
            label: "\(label) parent",
            createMissingDirectories: false
        ) { parentDescriptor in
            let createStatus = parsed.leaf.withCString {
                mkdirat(parentDescriptor, $0, mode_t(0o700))
            }
            let createError = errno
            guard createStatus == 0 else {
                if createError == EEXIST {
                    throw refusalError(
                        label: label,
                        path: url.path,
                        detail:
                            "the private staging directory already "
                            + "exists or is linked"
                    )
                }
                throw posixError(
                    "mkdirat private staging directory",
                    path: url.path,
                    code: createError
                )
            }

            let flags =
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            let descriptor = parsed.leaf.withCString {
                openat(parentDescriptor, $0, flags)
            }
            guard descriptor >= 0 else {
                throw posixError(
                    "openat private staging directory",
                    path: url.path
                )
            }
            defer { _ = close(descriptor) }
            guard fchmod(
                descriptor,
                S_IRUSR | S_IWUSR | S_IXUSR
            ) == 0 else {
                throw posixError(
                    "fchmod private staging directory",
                    path: url.path
                )
            }
            var opened = stat()
            var bound = stat()
            let bindingStatus = parsed.leaf.withCString {
                fstatat(
                    parentDescriptor,
                    $0,
                    &bound,
                    AT_SYMLINK_NOFOLLOW
                )
            }
            guard fstat(descriptor, &opened) == 0,
                  bindingStatus == 0,
                  opened.st_mode & mode_t(S_IFMT)
                    == mode_t(S_IFDIR),
                  opened.st_uid == geteuid(),
                  opened.st_mode & mode_t(0o777) == 0o700,
                  bound.st_dev == opened.st_dev,
                  bound.st_ino == opened.st_ino,
                  bound.st_mode & mode_t(S_IFMT)
                    == mode_t(S_IFDIR),
                  bound.st_uid == geteuid(),
                  bound.st_mode & mode_t(0o777) == 0o700 else {
                throw refusalError(
                    label: label,
                    path: url.path,
                    detail:
                        "the private staging directory binding or "
                        + "permissions are invalid"
                )
            }
            try requireNoExtendedACL(
                descriptor: descriptor,
                path: url.path,
                label: label
            )
            try synchronize(
                descriptor,
                operation:
                    "synchronize private staging directory",
                path: url.path
            )
            try synchronize(
                parentDescriptor,
                operation:
                    "synchronize private staging directory parent",
                path: url.deletingLastPathComponent().path
            )
        }
    }

    /// Removes only an empty physical directory and synchronizes its parent.
    /// A nonempty or replaced staging directory is deliberately left in place
    /// as fail-closed recovery evidence.
    public static func removeEmptyPrivateDirectory(
        _ url: URL,
        label: String
    ) throws {
        let parsed = try publicationComponents(url, label: label)
        try withAnchoredParentDirectory(
            components: parsed.parents,
            label: "\(label) parent",
            createMissingDirectories: false
        ) { parentDescriptor in
            let flags =
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            let descriptor = parsed.leaf.withCString {
                openat(parentDescriptor, $0, flags)
            }
            guard descriptor >= 0 else {
                throw posixError(
                    "openat private staging directory removal",
                    path: url.path
                )
            }
            defer { _ = close(descriptor) }
            var opened = stat()
            var bound = stat()
            let bindingStatus = parsed.leaf.withCString {
                fstatat(
                    parentDescriptor,
                    $0,
                    &bound,
                    AT_SYMLINK_NOFOLLOW
                )
            }
            guard fstat(descriptor, &opened) == 0,
                  bindingStatus == 0,
                  opened.st_mode & mode_t(S_IFMT)
                    == mode_t(S_IFDIR),
                  opened.st_uid == geteuid(),
                  opened.st_mode & mode_t(0o077) == 0,
                  bound.st_dev == opened.st_dev,
                  bound.st_ino == opened.st_ino,
                  bound.st_mode & mode_t(S_IFMT)
                    == mode_t(S_IFDIR) else {
                throw refusalError(
                    label: label,
                    path: url.path,
                    detail:
                        "the private staging directory is not an "
                        + "owned private physical directory"
                )
            }
            try requireNoExtendedACL(
                descriptor: descriptor,
                path: url.path,
                label: label
            )
            let removeStatus = parsed.leaf.withCString {
                unlinkat(parentDescriptor, $0, AT_REMOVEDIR)
            }
            let removeError = errno
            guard removeStatus == 0 else {
                throw posixError(
                    "unlinkat empty private staging directory",
                    path: url.path,
                    code: removeError
                )
            }
            try synchronize(
                parentDescriptor,
                operation:
                    "synchronize private staging directory removal",
                path: url.deletingLastPathComponent().path
            )
        }
    }

    /// Publishes complete bytes without replacing an existing directory
    /// entry. Every lookup is relative to an already-open non-symlink
    /// directory, and both file data and directory metadata are synchronized.
    public static func writeDataNoReplaceOrVerify(
        _ data: Data,
        to url: URL,
        label: String
    ) throws {
        try writeDataNoReplaceOrVerify(
            data,
            to: url,
            label: label,
            beforeRename: nil
        )
    }

    /// Internal publication seam used by deterministic race tests.
    static func writeDataNoReplaceOrVerify(
        _ data: Data,
        to url: URL,
        label: String,
        beforeRename: ((URL) throws -> Void)?
    ) throws {
        let parsed = try publicationComponents(url, label: label)
        try withAnchoredParentDirectory(
            components: parsed.parents,
            label: "\(label) parent"
        ) { parentDescriptor in
            if try verifyExistingData(
                data,
                parentDescriptor: parentDescriptor,
                leaf: parsed.leaf,
                path: url.path,
                label: label
            ) {
                return
            }

            let temporaryName =
                ".prime-artifact-partial-\(UUID().uuidString)"
            let createFlags =
                O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW
                | O_CLOEXEC
            let descriptor = temporaryName.withCString {
                openat(
                    parentDescriptor,
                    $0,
                    createFlags,
                    mode_t(0o600)
                )
            }
            guard descriptor >= 0 else {
                throw posixError(
                    "openat temporary output",
                    path:
                        url.deletingLastPathComponent()
                            .appendingPathComponent(
                                temporaryName
                            ).path
                )
            }
            defer { _ = close(descriptor) }

            var temporaryExists = true
            func removeTemporaryDurably() throws {
                guard temporaryExists else { return }
                let status = temporaryName.withCString {
                    unlinkat(parentDescriptor, $0, 0)
                }
                let code = errno
                guard status == 0 else {
                    throw posixError(
                        "unlinkat temporary output",
                        path: temporaryName,
                        code: code
                    )
                }
                temporaryExists = false
                try synchronize(
                    parentDescriptor,
                    operation:
                        "synchronize temporary output parent",
                    path: url.deletingLastPathComponent().path
                )
            }

            do {
                guard fchmod(
                    descriptor,
                    S_IRUSR | S_IWUSR
                ) == 0 else {
                    throw posixError(
                        "fchmod temporary output",
                        path: temporaryName
                    )
                }
                try data.withUnsafeBytes { rawBuffer in
                    var offset = 0
                    while offset < rawBuffer.count {
                        let count = write(
                            descriptor,
                            rawBuffer.baseAddress!.advanced(
                                by: offset
                            ),
                            rawBuffer.count - offset
                        )
                        if count < 0, errno == EINTR { continue }
                        guard count > 0 else {
                            throw posixError(
                                "write temporary output",
                                path: temporaryName
                            )
                        }
                        offset += count
                    }
                }
                try synchronize(
                    descriptor,
                    operation:
                        "synchronize temporary output",
                    path: temporaryName
                )
                try requireSingleLinkedRegularFile(
                    descriptor: descriptor,
                    parentDescriptor: parentDescriptor,
                    name: temporaryName,
                    path: temporaryName,
                    label: label,
                    expectedLinkCount: 1
                )

                try beforeRename?(
                    url.deletingLastPathComponent()
                        .appendingPathComponent(temporaryName)
                )
                let renameStatus = renameNoReplace(
                    sourceParentDescriptor: parentDescriptor,
                    sourceName: temporaryName,
                    destinationParentDescriptor: parentDescriptor,
                    destinationName: parsed.leaf
                )
                let renameError = errno
                if renameStatus != 0 {
                    if renameError == EEXIST {
                        let exact = try verifyExistingData(
                            data,
                            parentDescriptor: parentDescriptor,
                            leaf: parsed.leaf,
                            path: url.path,
                            label: label
                        )
                        guard exact else {
                            throw refusalError(
                                label: label,
                                path: url.path,
                                detail:
                                    "a racing output disappeared "
                                    + "before verification"
                            )
                        }
                        try removeTemporaryDurably()
                        return
                    }
                    throw posixError(
                        "no-replace rename publication",
                        path: url.path,
                        code: renameError
                    )
                }
                temporaryExists = false

                try requireSingleLinkedRegularFile(
                    descriptor: descriptor,
                    parentDescriptor: parentDescriptor,
                    name: parsed.leaf,
                    path: url.path,
                    label: label,
                    expectedLinkCount: 1
                )
                try synchronize(
                    parentDescriptor,
                    operation:
                        "synchronize publication parent",
                    path: url.deletingLastPathComponent().path
                )
            } catch {
                let publicationError = error
                do {
                    try removeTemporaryDurably()
                } catch {
                    throw NSError(
                        domain:
                            "ErgenticsNativeLanguageArtifactPathSafety",
                        code: 10,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "publication failed and temporary "
                                + "cleanup also failed for \(label): "
                                + "\(publicationError); cleanup: "
                                + "\(error)",
                        ]
                    )
                }
                throw publicationError
            }
        }
    }

    /// Promotes a private, single-link regular file with one atomic,
    /// no-replace namespace transition. Source and destination may use
    /// different directories on the same physical filesystem.
    public static func moveRegularFileNoReplace(
        from source: URL,
        to destination: URL,
        label: String
    ) throws {
        try moveRegularFileNoReplace(
            from: source,
            to: destination,
            label: label,
            beforeRename: nil
        )
    }

    /// Internal publication seam used by deterministic race tests.
    static func moveRegularFileNoReplace(
        from source: URL,
        to destination: URL,
        label: String,
        beforeRename: (() throws -> Void)?
    ) throws {
        let parsedSource = try publicationComponents(
            source,
            label: "\(label) source"
        )
        let parsedDestination = try publicationComponents(
            destination,
            label: "\(label) destination"
        )
        guard Array(parsedSource.parents)
                != Array(parsedDestination.parents)
                || parsedSource.leaf
                    != parsedDestination.leaf else {
            throw refusalError(
                label: label,
                path: destination.path,
                detail:
                    "source and destination must be distinct files"
            )
        }

        func performMove(
            sourceParentDescriptor: Int32,
            destinationParentDescriptor: Int32
        ) throws {
            let sourceFlags =
                O_RDWR | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC
            let sourceDescriptor =
                parsedSource.leaf.withCString {
                    openat(
                        sourceParentDescriptor,
                        $0,
                        sourceFlags
                    )
                }
            guard sourceDescriptor >= 0 else {
                throw posixError(
                    "openat move source",
                    path: source.path
                )
            }
            defer { _ = close(sourceDescriptor) }

            try requireSingleLinkedRegularFile(
                descriptor: sourceDescriptor,
                parentDescriptor: sourceParentDescriptor,
                name: parsedSource.leaf,
                path: source.path,
                label: label,
                expectedLinkCount: 1
            )
            guard fchmod(
                sourceDescriptor,
                S_IRUSR | S_IWUSR
            ) == 0 else {
                throw posixError(
                    "fchmod move source",
                    path: source.path
                )
            }
            try synchronize(
                sourceDescriptor,
                operation: "synchronize move source",
                path: source.path
            )
            try requireSingleLinkedRegularFile(
                descriptor: sourceDescriptor,
                parentDescriptor: sourceParentDescriptor,
                name: parsedSource.leaf,
                path: source.path,
                label: label,
                expectedLinkCount: 1
            )

            var destinationMetadata = stat()
            let destinationStatus =
                parsedDestination.leaf.withCString {
                    fstatat(
                        destinationParentDescriptor,
                        $0,
                        &destinationMetadata,
                        AT_SYMLINK_NOFOLLOW
                    )
                }
            if destinationStatus == 0 {
                throw refusalError(
                    label: label,
                    path: destination.path,
                    detail:
                        "the destination already exists or is linked"
                )
            }
            let destinationError = errno
            guard destinationError == ENOENT else {
                throw posixError(
                    "fstatat move destination",
                    path: destination.path,
                    code: destinationError
                )
            }

            try beforeRename?()
            let renameStatus = renameNoReplace(
                sourceParentDescriptor:
                    sourceParentDescriptor,
                sourceName: parsedSource.leaf,
                destinationParentDescriptor:
                    destinationParentDescriptor,
                destinationName: parsedDestination.leaf
            )
            let renameError = errno
            guard renameStatus == 0 else {
                if renameError == EEXIST {
                    throw refusalError(
                        label: label,
                        path: destination.path,
                        detail:
                            "the destination raced with publication"
                    )
                }
                throw posixError(
                    "no-replace rename move publication",
                    path: destination.path,
                    code: renameError
                )
            }

            try requireSingleLinkedRegularFile(
                descriptor: sourceDescriptor,
                parentDescriptor:
                    destinationParentDescriptor,
                name: parsedDestination.leaf,
                path: destination.path,
                label: label,
                expectedLinkCount: 1
            )
            var sourceAfter = stat()
            let sourceAfterStatus =
                parsedSource.leaf.withCString {
                    fstatat(
                        sourceParentDescriptor,
                        $0,
                        &sourceAfter,
                        AT_SYMLINK_NOFOLLOW
                    )
                }
            let sourceAfterError = errno
            guard sourceAfterStatus != 0,
                  sourceAfterError == ENOENT else {
                throw refusalError(
                    label: label,
                    path: source.path,
                    detail:
                        "the source binding still exists after "
                        + "atomic promotion"
                )
            }

            try synchronize(
                destinationParentDescriptor,
                operation:
                    "synchronize move publication parent",
                path: destination.deletingLastPathComponent().path
            )
            try synchronize(
                sourceParentDescriptor,
                operation: "synchronize move source parent",
                path: source.deletingLastPathComponent().path
            )
        }

        let sameParent =
            Array(parsedSource.parents)
                == Array(parsedDestination.parents)
        if sameParent {
            try withAnchoredParentDirectory(
                components: parsedSource.parents,
                label: "\(label) parent",
                createMissingDirectories: false
            ) { parentDescriptor in
                try performMove(
                    sourceParentDescriptor: parentDescriptor,
                    destinationParentDescriptor:
                        parentDescriptor
                )
            }
        } else {
            try withAnchoredParentDirectory(
                components: parsedSource.parents,
                label: "\(label) source parent",
                createMissingDirectories: false
            ) { sourceParentDescriptor in
                try withAnchoredParentDirectory(
                    components: parsedDestination.parents,
                    label: "\(label) destination parent",
                    createMissingDirectories: false
                ) { destinationParentDescriptor in
                    try performMove(
                        sourceParentDescriptor:
                            sourceParentDescriptor,
                        destinationParentDescriptor:
                            destinationParentDescriptor
                    )
                }
            }
        }
    }
}
