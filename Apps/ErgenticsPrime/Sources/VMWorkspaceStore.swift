import CryptoKit
import Darwin
import Foundation

/// Files for an ordinary, local Linux VM. These files are not H3/H8 receipts.
struct VMWorkspace: Codable, Identifiable, Equatable, Sendable {
    static let formatVersion = 2
    var version = formatVersion
    let id: UUID
    let name: String
    let createdAt: Date
    let cpuCount: Int
    let memoryGiB: Int
    let diskGiB: Int
    let machineIdentifier: Data
    let installerName: String
    let installerSHA256: String
    let installerBytes: Int64
    var installerAttached: Bool
    var suspendedState: String?
    var suspendedFiles: VMWorkspaceSuspendBinding? = nil

    var resourceSummary: String { "\(cpuCount) CPUs · \(memoryGiB) GB memory · \(diskGiB) GB disk" }
}

/// File identity and change metadata for a suspended session. It rejects
/// ordinary disk/EFI edits after suspend; it is not a cryptographic snapshot
/// or protection against a compromised host.
struct VMWorkspaceFileStamp: Codable, Equatable, Sendable {
    let device: Int32
    let inode: UInt64
    let bytes: Int64
    let modifiedSeconds: Int64
    let modifiedNanoseconds: Int64
    let changedSeconds: Int64
    let changedNanoseconds: Int64
}

struct VMWorkspaceSuspendBinding: Codable, Equatable, Sendable {
    let disk: VMWorkspaceFileStamp
    let efi: VMWorkspaceFileStamp
    let state: VMWorkspaceFileStamp
    let installer: VMWorkspaceFileStamp?
}

struct VMWorkspaceSetup: Sendable {
    var name = "Linux VM"
    var cpuCount = 2
    var memoryGiB = 4
    var diskGiB = 64

    func validate() throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= 80,
              !trimmed.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }),
              (1...8).contains(cpuCount), (2...16).contains(memoryGiB),
              (16...128).contains(diskGiB) else {
            throw VMWorkspaceFailure("Choose a name of 1–80 characters, 1–8 CPUs, 2–16 GB memory, and 16–128 GB disk.")
        }
    }
}

struct VMWorkspaceFailure: LocalizedError, Sendable {
    let message: String
    init(_ message: String) { self.message = message }
    var errorDescription: String? { message }
}

/// Only VMWorkspaceModel holds this lease. It excludes another app instance
/// from opening the same writable disk while this VM is active.
final class VMWorkspaceLease {
    private let descriptor: Int32
    init(directory: URL) throws {
        descriptor = Darwin.open(directory.appendingPathComponent("Run.lock").path,
                                 O_RDWR | O_CREAT | O_NOFOLLOW | O_CLOEXEC, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else { throw VMWorkspaceFailure("Could not open this VM's run lock.") }
        var info = stat()
        guard fstat(descriptor, &info) == 0, info.st_mode & S_IFMT == S_IFREG,
              info.st_uid == getuid(), info.st_nlink == 1,
              flock(descriptor, LOCK_EX | LOCK_NB) == 0 else {
            close(descriptor)
            throw VMWorkspaceFailure("This VM is already open in another app instance, or its run lock is unavailable.")
        }
    }
    deinit { flock(descriptor, LOCK_UN); close(descriptor) }
}

struct VMWorkspaceStore: Sendable {
    static let gib: Int64 = 1_073_741_824
    static let maximumInstallerBytes: Int64 = 16 * gib
    static let maximumMetadataBytes = 65_536
    let root: URL

    init(root: URL? = nil) throws {
        if let root { self.root = root }
        else {
            let support = try FileManager.default.url(for: .applicationSupportDirectory,
                in: .userDomainMask, appropriateFor: nil, create: true)
            self.root = support.appendingPathComponent("VMWorkspaces-v1", isDirectory: true)
        }
    }

    func directory(for id: UUID) -> URL {
        root.appendingPathComponent(id.uuidString.lowercased(), isDirectory: true)
    }
    func diskURL(for id: UUID) -> URL { directory(for: id).appendingPathComponent("Disk.img") }
    func installerURL(for id: UUID) -> URL { directory(for: id).appendingPathComponent("Installer.iso") }
    func efiURL(for id: UUID) -> URL { directory(for: id).appendingPathComponent("EFI.variables") }
    func stateURL(for workspace: VMWorkspace) throws -> URL {
        guard let name = workspace.suspendedState, Self.validStateName(name) else {
            throw VMWorkspaceFailure("This VM has no valid suspended state.")
        }
        return directory(for: workspace.id).appendingPathComponent(name)
    }
    static func validStateName(_ name: String) -> Bool {
        guard name.hasPrefix("State-"), name.hasSuffix(".vzsave") else { return false }
        let token = String(name.dropFirst(6).dropLast(7))
        return UUID(uuidString: token)?.uuidString.lowercased() == token
    }

    func list() throws -> (workspaces: [VMWorkspace], warnings: [String]) {
        guard FileManager.default.fileExists(atPath: root.path) else { return ([], []) }
        try validateDirectory(root)
        let children = try FileManager.default.contentsOfDirectory(at: root,
            includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        guard children.count <= 256 else { throw VMWorkspaceFailure("The VM folder contains too many entries to inspect safely.") }
        var workspaces: [VMWorkspace] = []
        var warnings: [String] = []
        for child in children.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            guard let id = UUID(uuidString: child.lastPathComponent),
                  id.uuidString.lowercased() == child.lastPathComponent else {
                warnings.append("Unrecognized item retained: \(child.lastPathComponent)")
                continue
            }
            do { workspaces.append(try load(id)) }
            catch { warnings.append("\(child.lastPathComponent): \(error.localizedDescription)") }
        }
        return (workspaces.sorted { $0.createdAt > $1.createdAt }, warnings)
    }

    /// The metadata read occurs only after acquiring the writable-disk lease.
    /// Callers must keep the returned lease throughout VM ownership.
    func acquire(_ id: UUID) throws -> (workspace: VMWorkspace, lease: VMWorkspaceLease) {
        try validateDirectory(root)
        try validateDirectory(directory(for: id))
        let lease = try VMWorkspaceLease(directory: directory(for: id))
        return (try load(id), lease)
    }

    func load(_ id: UUID) throws -> VMWorkspace {
        try validateDirectory(root)
        try validateDirectory(directory(for: id))
        let bytes = try readRegular(directory(for: id).appendingPathComponent("Workspace.json"),
                                    maximum: Self.maximumMetadataBytes)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let workspace = try decoder.decode(VMWorkspace.self, from: bytes)
        let setup = VMWorkspaceSetup(name: workspace.name, cpuCount: workspace.cpuCount,
            memoryGiB: workspace.memoryGiB, diskGiB: workspace.diskGiB)
        try setup.validate()
        guard workspace.version == VMWorkspace.formatVersion, workspace.id == id,
              !workspace.machineIdentifier.isEmpty, workspace.machineIdentifier.count <= 1_024,
              workspace.installerBytes > 0, workspace.installerBytes <= Self.maximumInstallerBytes,
              workspace.installerSHA256.count == 64,
              workspace.installerSHA256.allSatisfy({ "0123456789abcdef".contains($0) }),
              workspace.suspendedState.map(Self.validStateName) ?? true,
              (workspace.suspendedState == nil) == (workspace.suspendedFiles == nil),
              workspace.suspendedFiles.map({ ($0.installer != nil) == workspace.installerAttached }) ?? true else {
            throw VMWorkspaceFailure("The saved VM configuration is incomplete or unsupported.")
        }
        return workspace
    }

    /// Runs on the import worker. Failure/cancellation leaves a fresh partial
    /// directory for inspection; it never changes another workspace.
    func prepare(setup: VMWorkspaceSetup, iso: URL, machineIdentifier: Data,
                 progress: @Sendable (Double) -> Void) throws -> VMWorkspace {
        try setup.validate()
        try ensureRoot()
        let id = UUID()
        let directory = directory(for: id)
        guard mkdir(directory.path, S_IRWXU) == 0 else { throw posix("Could not create a private VM folder") }
        let copy = try copyInstaller(from: iso, to: installerURL(for: id),
            requiredFreeBytes: Int64(setup.diskGiB + 2 * setup.memoryGiB) * Self.gib, progress: progress)
        try Task.checkCancellation()
        let disk = Darwin.open(diskURL(for: id).path, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                               S_IRUSR | S_IWUSR)
        guard disk >= 0 else { throw posix("Could not create the VM disk") }
        defer { close(disk) }
        guard ftruncate(disk, Int64(setup.diskGiB) * Self.gib) == 0, fsync(disk) == 0 else {
            throw posix("Could not size and save the VM disk")
        }
        return VMWorkspace(id: id, name: setup.name.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date(timeIntervalSince1970: Date().timeIntervalSince1970.rounded(.down)), cpuCount: setup.cpuCount, memoryGiB: setup.memoryGiB,
            diskGiB: setup.diskGiB, machineIdentifier: machineIdentifier,
            installerName: iso.lastPathComponent, installerSHA256: copy.digest,
            installerBytes: copy.bytes, installerAttached: true, suspendedState: nil)
    }

    func save(_ workspace: VMWorkspace) throws {
        try validateDirectory(directory(for: workspace.id))
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let bytes = try encoder.encode(workspace)
        guard bytes.count <= Self.maximumMetadataBytes else { throw VMWorkspaceFailure("The VM configuration is too large.") }
        try writeAtomic(bytes, destination: directory(for: workspace.id).appendingPathComponent("Workspace.json"))
    }

    /// Path checks precede framework opening. This is private local storage,
    /// not an attestation or a guarantee against a compromised host.
    func validateFiles(_ workspace: VMWorkspace) throws {
        try validateDirectory(root)
        try validateDirectory(directory(for: workspace.id))
        try validateRegular(diskURL(for: workspace.id), exactSize: Int64(workspace.diskGiB) * Self.gib)
        try validateRegular(efiURL(for: workspace.id), maximum: 64 * 1_048_576)
        if workspace.installerAttached {
            try validateRegular(installerURL(for: workspace.id), exactSize: workspace.installerBytes)
        }
        if workspace.suspendedState != nil {
            try validateRegular(try stateURL(for: workspace), maximum: 2 * Int64(workspace.memoryGiB) * Self.gib + Self.gib)
        }
    }

    /// Called while holding the run lease, after the VM has stopped and before
    /// publishing a restore reference. It never copies or overwrites the disk.
    func bindSuspendedFiles(_ workspace: VMWorkspace) throws -> VMWorkspaceSuspendBinding {
        try validateFiles(workspace)
        return try VMWorkspaceSuspendBinding(disk: stamp(diskURL(for: workspace.id)),
            efi: stamp(efiURL(for: workspace.id)), state: stamp(stateURL(for: workspace)),
            installer: workspace.installerAttached ? stamp(installerURL(for: workspace.id)) : nil)
    }

    func verifySuspendedFiles(_ workspace: VMWorkspace) throws {
        guard workspace.suspendedState != nil, let expected = workspace.suspendedFiles else {
            throw VMWorkspaceFailure("This VM has no complete suspended session. Refresh the workspace.")
        }
        guard try bindSuspendedFiles(workspace) == expected else {
            throw VMWorkspaceFailure("The VM disk, EFI storage, attached installer, or suspended file changed after suspend. Restore was refused. Start from disk to begin a new session; retained files are unchanged.")
        }
    }

    private func stamp(_ url: URL) throws -> VMWorkspaceFileStamp {
        let fd = Darwin.open(url.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard fd >= 0 else { throw VMWorkspaceFailure("A suspended VM file could not be inspected: \(url.lastPathComponent)") }
        defer { close(fd) }
        var info = stat()
        guard fstat(fd, &info) == 0, info.st_mode & S_IFMT == S_IFREG,
              info.st_uid == getuid(), info.st_nlink == 1, info.st_mode & 0o077 == 0 else {
            throw VMWorkspaceFailure("A suspended VM file is no longer private: \(url.lastPathComponent)")
        }
        return VMWorkspaceFileStamp(device: info.st_dev, inode: info.st_ino, bytes: info.st_size,
            modifiedSeconds: Int64(info.st_mtimespec.tv_sec), modifiedNanoseconds: Int64(info.st_mtimespec.tv_nsec),
            changedSeconds: Int64(info.st_ctimespec.tv_sec), changedNanoseconds: Int64(info.st_ctimespec.tv_nsec))
    }

    func newStateURL(_ workspace: VMWorkspace) throws -> URL {
        let entries = try FileManager.default.contentsOfDirectory(atPath: directory(for: workspace.id).path)
        guard entries.filter({ Self.validStateName($0) }).count < 16 else {
            throw VMWorkspaceFailure("This VM has 16 retained suspend files. Shut down normally, or archive older files before saving another suspended state.")
        }
        return directory(for: workspace.id).appendingPathComponent("State-\(UUID().uuidString.lowercased()).vzsave")
    }

    func record(_ event: String, workspace: VMWorkspace) throws {
        let entry: [String: String] = ["time": ISO8601DateFormatter().string(from: Date()),
                                      "event": String(event.prefix(2_000))]
        var data = try JSONSerialization.data(withJSONObject: entry, options: [.sortedKeys])
        data.append(0x0a)
        let fd = Darwin.open(directory(for: workspace.id).appendingPathComponent("Activity.jsonl").path,
            O_WRONLY | O_CREAT | O_APPEND | O_NOFOLLOW | O_CLOEXEC, S_IRUSR | S_IWUSR)
        guard fd >= 0 else { throw posix("Could not save the VM activity record") }
        defer { close(fd) }
        var info = stat()
        guard fstat(fd, &info) == 0, info.st_mode & S_IFMT == S_IFREG,
              info.st_uid == getuid(), info.st_nlink == 1,
              info.st_size + Int64(data.count) <= 4 * 1_048_576 else {
            throw VMWorkspaceFailure("The VM activity record is unavailable or has reached 4 MB; existing records are retained.")
        }
        try writeAll(data, to: fd)
        guard fsync(fd) == 0 else { throw posix("Could not sync the VM activity record") }
    }

    private func ensureRoot() throws {
        if mkdir(root.path, S_IRWXU) != 0 && errno != EEXIST { throw posix("Could not create the VM folder") }
        try validateDirectory(root)
    }
    private func validateDirectory(_ url: URL) throws {
        var info = stat()
        guard lstat(url.path, &info) == 0, info.st_mode & S_IFMT == S_IFDIR,
              info.st_uid == getuid(), info.st_mode & 0o077 == 0 else {
            throw VMWorkspaceFailure("The VM folder is missing, shared, or is not a private directory: \(url.lastPathComponent)")
        }
    }
    private func validateRegular(_ url: URL, exactSize: Int64? = nil, maximum: Int64? = nil) throws {
        let fd = Darwin.open(url.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard fd >= 0 else { throw VMWorkspaceFailure("A VM file is missing or cannot be opened: \(url.lastPathComponent)") }
        defer { close(fd) }
        var info = stat()
        guard fstat(fd, &info) == 0, info.st_mode & S_IFMT == S_IFREG,
              info.st_uid == getuid(), info.st_nlink == 1, info.st_mode & 0o077 == 0,
              info.st_size > 0, exactSize.map({ info.st_size == $0 }) ?? true,
              maximum.map({ info.st_size <= $0 }) ?? true else {
            throw VMWorkspaceFailure("A VM file has changed type, permissions, or size: \(url.lastPathComponent)")
        }
    }
    private func readRegular(_ url: URL, maximum: Int) throws -> Data {
        let fd = Darwin.open(url.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard fd >= 0 else { throw VMWorkspaceFailure("No complete VM configuration was saved. Any partial files have been kept.") }
        defer { close(fd) }
        var info = stat()
        guard fstat(fd, &info) == 0, info.st_mode & S_IFMT == S_IFREG,
              info.st_uid == getuid(), info.st_nlink == 1, info.st_size > 0,
              info.st_size <= maximum, info.st_mode & 0o077 == 0 else {
            throw VMWorkspaceFailure("The VM configuration is not a private bounded file.")
        }
        var result = Data(count: Int(info.st_size))
        let count = result.withUnsafeMutableBytes { buffer in Darwin.read(fd, buffer.baseAddress, buffer.count) }
        guard count == result.count else { throw VMWorkspaceFailure("Could not read the complete VM configuration.") }
        return result
    }
    private func writeAtomic(_ bytes: Data, destination: URL) throws {
        let temporary = destination.deletingLastPathComponent().appendingPathComponent(".configuration-\(UUID().uuidString)")
        let fd = Darwin.open(temporary.path, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, S_IRUSR | S_IWUSR)
        guard fd >= 0 else { throw posix("Could not prepare VM configuration") }
        defer { close(fd) }
        try writeAll(bytes, to: fd)
        guard fsync(fd) == 0, rename(temporary.path, destination.path) == 0 else {
            throw posix("Could not publish VM configuration")
        }
        let parent = Darwin.open(destination.deletingLastPathComponent().path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard parent >= 0 else { throw posix("Could not open VM configuration folder") }
        defer { close(parent) }
        guard fsync(parent) == 0 else { throw posix("Could not sync VM configuration folder") }
    }
    private func writeAll(_ data: Data, to fd: Int32) throws {
        try data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let amount = Darwin.write(fd, bytes.baseAddress!.advanced(by: offset), bytes.count - offset)
                if amount < 0 && errno == EINTR { continue }
                guard amount > 0 else { throw posix("Could not write VM file") }
                offset += amount
            }
        }
    }
    private func copyInstaller(from source: URL, to destination: URL,
                               requiredFreeBytes: Int64, progress: @Sendable (Double) -> Void) throws -> (bytes: Int64, digest: String) {
        let input = Darwin.open(source.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard input >= 0 else { throw posix("Could not read the selected installer") }
        defer { close(input) }
        var before = stat()
        guard fstat(input, &before) == 0, before.st_mode & S_IFMT == S_IFREG,
              before.st_size > 32_768, before.st_size <= Self.maximumInstallerBytes else {
            throw VMWorkspaceFailure("Choose a regular ARM64 Linux installer ISO no larger than 16 GB.")
        }
        let attributes = try FileManager.default.attributesOfFileSystem(forPath: root.path)
        guard let available = attributes[.systemFreeSize] as? NSNumber,
              available.int64Value >= requiredFreeBytes + before.st_size else {
            throw VMWorkspaceFailure("There is not enough free space for the selected disk, installer, and a suspended session. Choose a smaller VM or free storage first.")
        }
        var signature = [UInt8](repeating: 0, count: 5)
        guard pread(input, &signature, signature.count, 32_769) == 5,
              signature == Array("CD001".utf8) else {
            throw VMWorkspaceFailure("The selected file is not an ISO 9660 installer image. Choose an ARM64 Linux UEFI installer ISO.")
        }
        let output = Darwin.open(destination.path, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                                 S_IRUSR | S_IWUSR)
        guard output >= 0 else { throw posix("Could not import the installer into this VM") }
        defer { close(output) }
        let began = ContinuousClock.now
        var buffer = [UInt8](repeating: 0, count: 1_048_576)
        var total: Int64 = 0
        var lastProgress = -1
        var hasher = SHA256()
        while true {
            try Task.checkCancellation()
            guard began.duration(to: .now) < .seconds(1_800) else { throw VMWorkspaceFailure("Installer import exceeded 30 minutes; partial files were retained.") }
            let count = Darwin.read(input, &buffer, buffer.count)
            if count < 0 && errno == EINTR { continue }
            guard count >= 0 else { throw posix("Could not read installer bytes") }
            if count == 0 { break }
            total += Int64(count)
            guard total <= before.st_size else { throw VMWorkspaceFailure("The installer changed during import.") }
            let data = Data(buffer.prefix(count))
            hasher.update(data: data)
            try writeAll(data, to: output)
            let percent = Int(total * 100 / before.st_size)
            if percent != lastProgress {
                lastProgress = percent
                progress(Double(total) / Double(before.st_size))
            }
        }
        var after = stat()
        guard fstat(input, &after) == 0, total == before.st_size, after.st_size == before.st_size,
              after.st_mtimespec.tv_sec == before.st_mtimespec.tv_sec,
              after.st_mtimespec.tv_nsec == before.st_mtimespec.tv_nsec,
              after.st_ctimespec.tv_sec == before.st_ctimespec.tv_sec,
              after.st_ctimespec.tv_nsec == before.st_ctimespec.tv_nsec else {
            throw VMWorkspaceFailure("The installer changed during import; choose it again.")
        }
        guard fsync(output) == 0 else { throw posix("Could not sync the imported installer") }
        return (total, hasher.finalize().map { String(format: "%02x", $0) }.joined())
    }
    private func posix(_ message: String) -> VMWorkspaceFailure {
        VMWorkspaceFailure("\(message): \(String(cString: strerror(errno)))")
    }
}
