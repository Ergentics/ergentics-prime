import Darwin
import Foundation

struct ErgenticsAgentMessage: Codable, Identifiable, Hashable, Sendable {
    enum Author: String, Codable, Sendable { case user }
    let id: UUID
    let author: Author
    let text: String
    let createdAt: Date
}

struct ErgenticsAgentPrimeRun: Codable, Identifiable, Hashable, Sendable {
    enum Outcome: String, Codable, Sendable { case running, completed, stopped, failed, interrupted }
    let id: UUID
    let input: String
    var output: String
    var status: String
    var outcome: Outcome
    let startedAt: Date
    var completedAt: Date?
    var generatedTokens: Int?
    var elapsedSeconds: Double?
    var userMessageID: UUID? = nil
}

struct ErgenticsAgentTask: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var title: String
    var profileID: String
    var requestedModel: String
    var selectedLessonIDs: [String]
    var messages: [ErgenticsAgentMessage]
    var draft: String?
    var primeRuns: [ErgenticsAgentPrimeRun]?
    var createdAt: Date
    var updatedAt: Date

    static func fresh(profileID: String = "ergentics_swift_c") -> Self {
        let now = Date()
        return Self(id: UUID(), title: "New local task", profileID: profileID,
                    requestedModel: "Ergentics Prime · local experiment", selectedLessonIDs: [],
                    messages: [], draft: nil, primeRuns: [], createdAt: now, updatedAt: now)
    }
}

/// Private, bounded persistence for user messages and actual Prime run observations.
/// Corrupt or unsafe bytes are never replaced; recovery creates a distinct store.
final class ErgenticsAgentTaskStore {
    private let directory: URL
    private let fileManager: FileManager
    private let maximumTasks = 40
    private let maximumMessagesPerTask = 300
    private let maximumMessageBytes = 8_192
    private let maximumRunsPerTask = 100
    private let maximumRunOutputBytes = 65_536

    init(directory: URL, fileManager: FileManager = .default) {
        self.directory = directory
        self.fileManager = fileManager
    }

    static func appContainer(fileManager: FileManager = .default, recoveryID: UUID? = nil) throws -> Self {
        let support = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                          appropriateFor: nil, create: true)
        let name = recoveryID.map { "ErgenticsAgentTasks-\($0.uuidString.lowercased())" } ?? "ErgenticsAgentTasks"
        return Self(directory: support.appendingPathComponent(name, isDirectory: true), fileManager: fileManager)
    }

    func load() throws -> [ErgenticsAgentTask] {
        var named = stat()
        if lstat(directory.path, &named) != 0 {
            guard errno == ENOENT else { throw StoreError.directoryUnsafe }
            return []
        }
        let directoryFD = try openPrivateDirectory(create: false)
        defer { _ = Darwin.close(directoryFD) }
        guard try exists("tasks.json", directoryFD: directoryFD) else { return [] }
        let data = try readPrivateFile("tasks.json", directoryFD: directoryFD, limit: 1_048_576)
        return try validated(JSONDecoder.agentTasks.decode([ErgenticsAgentTask].self, from: data))
    }

    func save(_ tasks: [ErgenticsAgentTask]) throws {
        let checked = try validated(tasks)
        let data = try JSONEncoder.pretty.encode(checked)
        guard data.count <= 1_048_576 else { throw StoreError.tooLarge }
        let directoryFD = try openPrivateDirectory(create: true)
        defer { _ = Darwin.close(directoryFD) }
        // Also preserve damage discovered after the workspace was opened.
        // This is not isolation from concurrent writes by the same OS user.
        if try exists("tasks.json", directoryFD: directoryFD) {
            let prior = try readPrivateFile("tasks.json", directoryFD: directoryFD, limit: 1_048_576)
            _ = try validated(JSONDecoder.agentTasks.decode([ErgenticsAgentTask].self, from: prior))
        }
        let temporary = ".tasks-\(UUID().uuidString.lowercased()).tmp"
        let fd = temporary.withCString { Darwin.openat(directoryFD, $0, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600) }
        guard fd >= 0 else { throw StoreError.writeFailed }
        do {
            defer { _ = Darwin.close(fd) }
            try writeAll(data, descriptor: fd)
            guard fsync(fd) == 0 else { throw StoreError.writeFailed }
        } catch {
            _ = temporary.withCString { Darwin.unlinkat(directoryFD, $0, 0) }
            throw error
        }
        let renamed = temporary.withCString { source in
            "tasks.json".withCString { target in Darwin.renameat(directoryFD, source, directoryFD, target) }
        }
        guard renamed == 0, fsync(directoryFD) == 0 else {
            _ = temporary.withCString { Darwin.unlinkat(directoryFD, $0, 0) }
            throw StoreError.writeFailed
        }
    }

    private func validated(_ tasks: [ErgenticsAgentTask]) throws -> [ErgenticsAgentTask] {
        guard tasks.count <= maximumTasks else { throw StoreError.tooManyTasks }
        var ids = Set<UUID>()
        for task in tasks {
            guard ids.insert(task.id).inserted, !task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  task.title.utf8.count <= 256, task.profileID.utf8.count <= 128,
                  task.requestedModel.utf8.count <= 128, (task.draft?.utf8.count ?? 0) <= maximumMessageBytes, task.selectedLessonIDs.count <= 8,
                  task.messages.count <= maximumMessagesPerTask, (task.primeRuns ?? []).count <= maximumRunsPerTask else { throw StoreError.invalidTask }
            for message in task.messages where message.text.utf8.count > maximumMessageBytes { throw StoreError.invalidTask }
            for run in task.primeRuns ?? [] where run.input.utf8.count > 4_096 || run.input.precomposedStringWithCanonicalMapping.utf8.count > 1_023 || run.output.utf8.count > maximumRunOutputBytes { throw StoreError.invalidTask }
        }
        return tasks.sorted { $0.updatedAt > $1.updatedAt }
    }

    private func openPrivateDirectory(create: Bool) throws -> Int32 {
        if create {
            let result = Darwin.mkdir(directory.path, 0o700)
            guard result == 0 || errno == EEXIST else { throw StoreError.directoryUnsafe }
        }
        let fd = Darwin.open(directory.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard fd >= 0 else { throw StoreError.directoryUnsafe }
        var info = stat()
        guard fstat(fd, &info) == 0, info.st_mode & S_IFMT == S_IFDIR, info.st_uid == geteuid(), info.st_mode & 0o7777 == 0o700 else {
            _ = Darwin.close(fd); throw StoreError.directoryUnsafe
        }
        return fd
    }

    private func exists(_ name: String, directoryFD: Int32) throws -> Bool {
        var info = stat()
        let result = name.withCString { Darwin.fstatat(directoryFD, $0, &info, AT_SYMLINK_NOFOLLOW) }
        if result == 0 { return true }
        if errno == ENOENT { return false }
        throw StoreError.readFailed
    }

    private func readPrivateFile(_ name: String, directoryFD: Int32, limit: Int) throws -> Data {
        let fd = name.withCString { Darwin.openat(directoryFD, $0, O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK) }
        guard fd >= 0 else { throw StoreError.readFailed }
        defer { _ = Darwin.close(fd) }
        var before = stat()
        guard fstat(fd, &before) == 0, before.st_mode & S_IFMT == S_IFREG, before.st_uid == geteuid(),
              before.st_mode & 0o7777 == 0o600, before.st_size >= 0, before.st_size <= off_t(limit) else { throw StoreError.readFailed }
        var data = Data(); data.reserveCapacity(Int(before.st_size)); var buffer = [UInt8](repeating: 0, count: 65_536)
        while true {
            let count = buffer.withUnsafeMutableBytes { Darwin.read(fd, $0.baseAddress, $0.count) }
            if count < 0 && errno == EINTR { continue }
            guard count >= 0 else { throw StoreError.readFailed }
            if count == 0 { break }
            data.append(buffer, count: count)
            guard data.count <= limit else { throw StoreError.readFailed }
        }
        var after = stat()
        guard fstat(fd, &after) == 0, before.st_dev == after.st_dev, before.st_ino == after.st_ino, after.st_size == off_t(data.count) else { throw StoreError.readFailed }
        return data
    }

    private func writeAll(_ data: Data, descriptor: Int32) throws {
        try data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let count = Darwin.write(descriptor, bytes.baseAddress!.advanced(by: offset), bytes.count - offset)
                if count < 0 && errno == EINTR { continue }
                guard count > 0 else { throw StoreError.writeFailed }
                offset += count
            }
        }
    }

    enum StoreError: Error, Equatable, LocalizedError {
        case tooLarge, tooManyTasks, invalidTask, directoryUnsafe, readFailed, writeFailed
        var errorDescription: String? {
            switch self {
            case .tooLarge: "Agent task drafts exceed the local storage limit."
            case .tooManyTasks: "Keep at most 40 saved local agent tasks."
            case .invalidTask: "A saved agent task has an invalid field or exceeds a bounded limit."
            case .directoryUnsafe: "The private AgentTasks directory is missing or has an unsafe identity, owner, or mode."
            case .readFailed: "Saved AgentTasks data is unsafe, too large, or changed while it was read."
            case .writeFailed: "The local task draft could not be safely saved."
            }
        }
    }
}

private extension JSONEncoder { static var pretty: JSONEncoder { let value = JSONEncoder(); value.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]; value.dateEncodingStrategy = .iso8601; return value } }
private extension JSONDecoder { static var agentTasks: JSONDecoder { let value = JSONDecoder(); value.dateDecodingStrategy = .iso8601; return value } }
