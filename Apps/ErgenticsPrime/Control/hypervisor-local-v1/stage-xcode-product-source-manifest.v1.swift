import CryptoKit
import Darwin
import Foundation

@main
enum StageXcodeProductSourceManifestV1 {
    static let roots = [
        "Assets.xcassets",
        "Entitlements.plist",
        "ErgenticsProvenance.xcodeproj/project.pbxproj",
        "ErgenticsProvenance.xcodeproj/xcshareddata/xcschemes",
        "Guest",
        "Info.plist",
        "PrivacyInfo.xcprivacy",
        "Sources",
        "Tests",
    ]
    static let maximumEntries = 4_096
    static let maximumRegularBytes: UInt64 = 1_073_741_824
    static let maximumDepth = 64

    struct Entry {
        let path: String
        let type: String
        let mode: String
        let device: String
        let inode: String
        let size: String
        let modifiedSeconds: String
        let modifiedNanoseconds: String
        let changedSeconds: String
        let changedNanoseconds: String
        let payloadSHA256: String

        var row: String {
            [path, type, mode, device, inode, size, modifiedSeconds, modifiedNanoseconds,
             changedSeconds, changedNanoseconds, payloadSHA256].joined(separator: "\0")
        }

        var object: [String: String] {
            [
                "path": path,
                "type": type,
                "mode": mode,
                "device": device,
                "inode": inode,
                "size": size,
                "modified_seconds": modifiedSeconds,
                "modified_nanoseconds": modifiedNanoseconds,
                "changed_seconds": changedSeconds,
                "changed_nanoseconds": changedNanoseconds,
                "payload_sha256": payloadSHA256,
            ]
        }
    }

    static func main() throws {
        guard CommandLine.arguments.count == 1 else { throw Failure("arguments") }
        var entries: [Entry] = []
        var regularBytes: UInt64 = 0
        for path in roots {
            var namedBefore = stat()
            guard lstat(path, &namedBefore) == 0 else { throw Failure("root_lstat_\(errno)") }
            let kind = namedBefore.st_mode & S_IFMT
            let flags = kind == S_IFDIR ? O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC :
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            let descriptor = open(path, flags)
            guard descriptor >= 0 else { throw Failure("root_open_\(errno)") }
            defer { _ = close(descriptor) }
            var held = stat()
            guard fstat(descriptor, &held) == 0, sameIdentity(namedBefore, held) else {
                throw Failure("root_join")
            }
            if kind == S_IFDIR {
                entries.append(metadata(path: path, type: "directory", status: held, payload: "-"))
                try collectDirectory(descriptor, path: path, depth: 0,
                                     entries: &entries, regularBytes: &regularBytes)
            } else if kind == S_IFREG {
                let digest = try hashFile(descriptor, admitted: held)
                entries.append(metadata(path: path, type: "file", status: held, payload: digest))
                regularBytes = try addBytes(regularBytes, UInt64(held.st_size))
            } else {
                throw Failure("root_type")
            }
            var namedAfter = stat()
            var heldAfter = stat()
            guard lstat(path, &namedAfter) == 0, fstat(descriptor, &heldAfter) == 0,
                  sameStatus(namedBefore, namedAfter), sameStatus(held, heldAfter),
                  sameIdentity(namedAfter, heldAfter) else { throw Failure("root_rebound") }
        }

        entries.sort { $0.path.utf8.lexicographicallyPrecedes($1.path.utf8) }
        guard entries.count <= maximumEntries,
              Set(entries.map(\.path)).count == entries.count else { throw Failure("inventory") }
        let manifest = entries.map(\.row).joined(separator: "\n")
        let root = hex(Data(SHA256.hash(data: Data(manifest.utf8))))
        let files = entries.filter { $0.type == "file" }.count
        let directories = entries.filter { $0.type == "directory" }.count
        let object: [String: Any] = [
            "schema": "ergentics.provenance.hypervisor.xcode-product-source-manifest.v1",
            "hash_profile": [
                "entry_order": "UTF8_BYTEWISE_RELATIVE_PATH",
                "entry_separator": "LF",
                "field_separator": "NUL",
                "terminal_separator": false,
                "entry_fields": [
                    "path", "type", "mode", "device", "inode", "size",
                    "modified_seconds", "modified_nanoseconds", "changed_seconds",
                    "changed_nanoseconds", "payload_sha256",
                ],
                "root_hash": "SHA256",
            ],
            "fixed_roots": roots,
            "manifest_root_sha256": root,
            "entry_count": String(entries.count),
            "file_count": String(files),
            "directory_count": String(directories),
            "regular_file_bytes": String(regularBytes),
            "symlink_count": "0",
            "special_count": "0",
            "entries": entries.map(\.object),
        ]
        guard JSONSerialization.isValidJSONObject(object) else { throw Failure("json") }
        let bytes = try JSONSerialization.data(withJSONObject: object,
                                               options: [.sortedKeys, .withoutEscapingSlashes])
        FileHandle.standardOutput.write(bytes)
    }

    static func collectDirectory(_ descriptor: Int32, path: String, depth: Int,
                                 entries: inout [Entry], regularBytes: inout UInt64) throws {
        guard depth < maximumDepth else { throw Failure("depth") }
        let beforeNames = try directoryNames(descriptor)
        for name in beforeNames {
            let childPath = "\(path)/\(name)"
            var named = stat()
            let statResult = name.withCString {
                fstatat(descriptor, $0, &named, AT_SYMLINK_NOFOLLOW)
            }
            guard statResult == 0 else { throw Failure("child_lstat_\(errno)") }
            let kind = named.st_mode & S_IFMT
            if kind == S_IFLNK { throw Failure("symlink") }
            let flags = kind == S_IFDIR ? O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC :
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            let child = name.withCString { openat(descriptor, $0, flags) }
            guard child >= 0 else { throw Failure("child_open_\(errno)") }
            defer { _ = close(child) }
            var held = stat()
            guard fstat(child, &held) == 0, sameIdentity(named, held) else {
                throw Failure("child_join")
            }
            if kind == S_IFDIR {
                entries.append(metadata(path: childPath, type: "directory", status: held, payload: "-"))
                try collectDirectory(child, path: childPath, depth: depth + 1,
                                     entries: &entries, regularBytes: &regularBytes)
            } else if kind == S_IFREG {
                let digest = try hashFile(child, admitted: held)
                entries.append(metadata(path: childPath, type: "file", status: held, payload: digest))
                regularBytes = try addBytes(regularBytes, UInt64(held.st_size))
            } else {
                throw Failure("special")
            }
            var namedAfter = stat()
            var heldAfter = stat()
            let restat = name.withCString {
                fstatat(descriptor, $0, &namedAfter, AT_SYMLINK_NOFOLLOW)
            }
            guard restat == 0, fstat(child, &heldAfter) == 0,
                  sameStatus(named, namedAfter), sameStatus(held, heldAfter),
                  sameIdentity(namedAfter, heldAfter) else { throw Failure("child_rebound") }
        }
        guard try directoryNames(descriptor) == beforeNames else { throw Failure("directory_rebound") }
    }

    static func directoryNames(_ descriptor: Int32) throws -> [String] {
        let independent = openat(descriptor, ".", O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard independent >= 0, let directory = fdopendir(independent) else {
            if independent >= 0 { _ = close(independent) }
            throw Failure("fdopendir_\(errno)")
        }
        defer { _ = closedir(directory) }
        var result: [String] = []
        errno = 0
        while let entry = readdir(directory) {
            var rawName = entry.pointee.d_name
            let name = withUnsafePointer(to: &rawName) {
                $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN) + 1) {
                    String(validatingUTF8: $0)
                }
            }
            guard let name else { throw Failure("name_utf8") }
            if name == "." || name == ".." { continue }
            guard !name.isEmpty, !name.contains("/"), !name.utf8.contains(0) else {
                throw Failure("name")
            }
            result.append(name)
            guard result.count <= maximumEntries else { throw Failure("entry_bound") }
        }
        guard errno == 0 else { throw Failure("readdir_\(errno)") }
        result.sort { $0.utf8.lexicographicallyPrecedes($1.utf8) }
        guard Set(result).count == result.count else { throw Failure("duplicate_name") }
        return result
    }

    static func hashFile(_ descriptor: Int32, admitted: stat) throws -> String {
        guard lseek(descriptor, 0, SEEK_SET) == 0 else { throw Failure("seek") }
        var hasher = SHA256()
        var total: UInt64 = 0
        var buffer = [UInt8](repeating: 0, count: 65_536)
        while true {
            let count = buffer.withUnsafeMutableBytes { raw in
                Darwin.read(descriptor, raw.baseAddress, raw.count)
            }
            if count < 0 && errno == EINTR { continue }
            guard count >= 0 else { throw Failure("read_\(errno)") }
            if count == 0 { break }
            total = try addBytes(total, UInt64(count))
            hasher.update(data: Data(buffer[0..<count]))
        }
        var after = stat()
        guard fstat(descriptor, &after) == 0, sameStatus(admitted, after),
              total == UInt64(admitted.st_size) else { throw Failure("file_rebound") }
        return hex(Data(hasher.finalize()))
    }

    static func addBytes(_ lhs: UInt64, _ rhs: UInt64) throws -> UInt64 {
        let (sum, overflow) = lhs.addingReportingOverflow(rhs)
        guard !overflow, sum <= maximumRegularBytes else { throw Failure("byte_bound") }
        return sum
    }

    static func metadata(path: String, type: String, status: stat,
                         payload: String) -> Entry {
        Entry(path: path, type: type, mode: String(format: "%04o", status.st_mode & 0o7777),
              device: String(status.st_dev), inode: String(status.st_ino),
              size: String(status.st_size),
              modifiedSeconds: String(status.st_mtimespec.tv_sec),
              modifiedNanoseconds: String(status.st_mtimespec.tv_nsec),
              changedSeconds: String(status.st_ctimespec.tv_sec),
              changedNanoseconds: String(status.st_ctimespec.tv_nsec),
              payloadSHA256: payload)
    }

    static func sameIdentity(_ lhs: stat, _ rhs: stat) -> Bool {
        lhs.st_dev == rhs.st_dev && lhs.st_ino == rhs.st_ino &&
            (lhs.st_mode & S_IFMT) == (rhs.st_mode & S_IFMT)
    }

    static func sameStatus(_ lhs: stat, _ rhs: stat) -> Bool {
        sameIdentity(lhs, rhs) && lhs.st_mode == rhs.st_mode && lhs.st_size == rhs.st_size &&
            lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec &&
            lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec &&
            lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec &&
            lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
    }

    static func hex(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    struct Failure: Error {
        let reason: String
        init(_ reason: String) { self.reason = reason }
    }
}
