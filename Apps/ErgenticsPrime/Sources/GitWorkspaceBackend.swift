import Darwin
import Foundation
import Security

struct GitWorkspaceError: Error, LocalizedError, Sendable {
    let message: String
    var errorDescription: String? { message }
}

final class GitWorkspaceCancellation: @unchecked Sendable {
    private let lock = NSLock()
    private var requested = false
    func cancel() { lock.lock(); requested = true; lock.unlock() }
    var isCancelled: Bool { lock.lock(); defer { lock.unlock() }; return requested }
}

struct GitWorkspaceChange: Identifiable, Equatable, Sendable {
    let path: String
    let originalPath: String?
    let index: Character
    let worktree: Character
    var id: String { path }
    var staged: Bool { index != " " && index != "?" }
    var unstaged: Bool { worktree != " " }
    var untracked: Bool { index == "?" && worktree == "?" }
    var conflicted: Bool { index == "U" || worktree == "U" || (index == "A" && worktree == "A") || (index == "D" && worktree == "D") }
    var paths: [String] { originalPath.map { [$0, path] } ?? [path] }
    var label: String { originalPath.map { "\($0) → \(path)" } ?? path }
    var code: String { String(index) + String(worktree) }
}

struct GitWorkspaceCommit: Identifiable, Equatable, Sendable {
    let id: String
    let author: String
    let date: String
    let subject: String
}

struct GitWorkspaceSnapshot: Sendable {
    let root: URL
    let branch: String
    let head: String?
    let changes: [GitWorkspaceChange]
    let history: [GitWorkspaceCommit]
    let writeBlock: String?
    let authorName: String
    let authorEmail: String
}

/// Apple's /usr/bin/git is an xcrun launcher, which App Sandbox rejects.
/// Use an installed Apple Git directly; never discover executables through PATH.
enum GitWorkspaceExecutable {
    static let candidates = [
        "/Applications/Xcode.app/Contents/Developer/usr/bin/git",
        "/Library/Developer/CommandLineTools/usr/bin/git",
    ]

    static func select(accepts: (String) -> Bool) throws -> String {
        guard let path = candidates.first(where: accepts) else {
            throw GitWorkspaceError(message: "Git workspace requires Apple-signed Git from Xcode or Command Line Tools at their standard locations.")
        }
        return path
    }

    static func resolve() throws -> String {
        var requirement: SecRequirement?
        guard SecRequirementCreateWithString(
            "anchor apple and identifier \"com.apple.git\"" as CFString,
            [], &requirement
        ) == errSecSuccess, let requirement else {
            throw GitWorkspaceError(message: "Git's signing requirement could not be checked.")
        }
        return try select { path in
            var info = stat()
            guard lstat(path, &info) == 0, info.st_mode & S_IFMT == S_IFREG,
                  FileManager.default.isExecutableFile(atPath: path) else { return false }
            var code: SecStaticCode?
            guard SecStaticCodeCreateWithPath(URL(fileURLWithPath: path) as CFURL,
                [], &code) == errSecSuccess,
                  let code else { return false }
            let flags = SecCSFlags(rawValue: kSecCSStrictValidate | kSecCSCheckAllArchitectures)
                .union(.noNetworkAccess)
            return SecStaticCodeCheckValidity(code, flags,
                requirement) == errSecSuccess
        }
    }
}

/// A single owned git process group. No shell, network command, pager,
/// external diff, fsmonitor, hook, signing helper or automatic maintenance.
enum GitWorkspaceCommand {
    struct Output: Sendable { let status: Int32; let stdout: Data; let stderr: Data }
    static let common = ["--no-pager", "-c", "core.fsmonitor=false", "-c", "core.hooksPath=/dev/null",
        "-c", "core.untrackedCache=false", "-c", "gc.auto=0", "-c", "maintenance.auto=false",
        "-c", "commit.gpgSign=false", "-c", "tag.gpgSign=false", "-c", "log.showSignature=false",
        "-c", "diff.external=", "-c", "core.pager=cat", "-c", "protocol.allow=never",
        "-c", "credential.helper=", "-c", "core.askPass="]

    static func run(root: URL, arguments: [String], cancellation: GitWorkspaceCancellation,
                    environment: [String: String] = [:], seconds: Double = 20,
                    maximumBytes: Int = 2_097_152) throws -> Output {
        guard !cancellation.isCancelled else { throw GitWorkspaceError(message: "Canceled.") }
        let executable = try GitWorkspaceExecutable.resolve()
        guard !cancellation.isCancelled else { throw GitWorkspaceError(message: "Canceled.") }
        var out: [Int32] = [-1, -1], err: [Int32] = [-1, -1]
        guard pipe(&out) == 0 else { throw GitWorkspaceError(message: "Could not create Git output pipe.") }
        guard pipe(&err) == 0 else { out.forEach { close($0) }; throw GitWorkspaceError(message: "Could not create Git error pipe.") }
        defer { (out + err).filter { $0 >= 0 }.forEach { close($0) } }
        for fd in out + err { _ = fcntl(fd, F_SETFD, FD_CLOEXEC) }
        var actions: posix_spawn_file_actions_t?
        var attrs: posix_spawnattr_t?
        guard posix_spawn_file_actions_init(&actions) == 0 else { throw GitWorkspaceError(message: "Git launch setup failed.") }
        defer { posix_spawn_file_actions_destroy(&actions) }
        guard posix_spawnattr_init(&attrs) == 0 else { throw GitWorkspaceError(message: "Git launch attributes failed.") }
        defer { posix_spawnattr_destroy(&attrs) }
        let setup = [posix_spawn_file_actions_addchdir(&actions, root.path),
            posix_spawn_file_actions_addopen(&actions, STDIN_FILENO, "/dev/null", O_RDONLY, 0),
            posix_spawn_file_actions_adddup2(&actions, out[1], STDOUT_FILENO),
            posix_spawn_file_actions_adddup2(&actions, err[1], STDERR_FILENO),
            posix_spawn_file_actions_addclose(&actions, out[0]),
            posix_spawn_file_actions_addclose(&actions, err[0]),
            posix_spawn_file_actions_addclose(&actions, out[1]),
            posix_spawn_file_actions_addclose(&actions, err[1]),
            posix_spawnattr_setflags(&attrs, Int16(POSIX_SPAWN_SETPGROUP | POSIX_SPAWN_CLOEXEC_DEFAULT)),
            posix_spawnattr_setpgroup(&attrs, 0)]
        guard setup.allSatisfy({ $0 == 0 }) else { throw GitWorkspaceError(message: "Git launch setup was rejected.") }
        var values = ["PATH": "/usr/bin:/bin:/usr/sbin:/sbin", "LC_ALL": "C", "LANG": "C",
            "GIT_TERMINAL_PROMPT": "0", "GIT_PAGER": "cat", "GIT_LITERAL_PATHSPECS": "1",
            "GIT_OPTIONAL_LOCKS": "0", "GIT_NO_LAZY_FETCH": "1", "GIT_ALLOW_PROTOCOL": ""]
        // Preserve ordinary user Git configuration, while overriding executable
        // helpers per command and rejecting configured content filters on writes.
        for key in ["HOME", "XDG_CONFIG_HOME"] { values[key] = ProcessInfo.processInfo.environment[key] }
        for (key, value) in environment { values[key] = value }
        var argv = ([executable] + common + arguments).map { strdup($0) } + [nil]
        var envp = values.keys.sorted().map { strdup("\($0)=\(values[$0]!)") } + [nil]
        defer { argv.forEach { free($0) }; envp.forEach { free($0) } }
        var pid: pid_t = 0
        let spawned = posix_spawn(&pid, executable, &actions, &attrs, &argv, &envp)
        guard spawned == 0 else { throw GitWorkspaceError(message: "The verified Apple Git executable could not start (\(spawned)).") }
        close(out[1]); out[1] = -1; close(err[1]); err[1] = -1
        _ = fcntl(out[0], F_SETFL, O_NONBLOCK); _ = fcntl(err[0], F_SETFL, O_NONBLOCK)
        let began = ProcessInfo.processInfo.systemUptime
        var terminatedAt: Double?, termSent = false, killed = false, reaped = false, status: Int32 = 0
        var leaderExited = false
        var stdout = Data(), stderr = Data(), outEOF = false, errEOF = false
        var failure: String?
        func drain(_ fd: Int32, into data: inout Data, eof: inout Bool, bound: Int) {
            var buffer = [UInt8](repeating: 0, count: 16_384)
            while !eof {
                let count = read(fd, &buffer, buffer.count)
                if count == 0 { eof = true; break }
                if count < 0 {
                    if errno == EINTR { continue }
                    if errno != EAGAIN { failure = "Git output could not be read."; eof = true }
                    break
                }
                if data.count + count > bound { failure = "Git output exceeded the \(bound)-byte limit."; break }
                data.append(contentsOf: buffer.prefix(count))
            }
        }
        while true {
            drain(out[0], into: &stdout, eof: &outEOF, bound: maximumBytes)
            drain(err[0], into: &stderr, eof: &errEOF, bound: 65_536)
            if !leaderExited {
                var info = siginfo_t()
                let waited = waitid(P_PID, id_t(pid), &info, WEXITED | WNOHANG | WNOWAIT)
                if waited == 0, info.si_pid == pid { leaderExited = true }
                else if waited < 0, errno != EINTR { failure = "Git child exit could not be verified."; break }
            }
            if leaderExited && !reaped {
                // Keep the exited leader unreaped while retiring its entire
                // process group: its PID cannot be reused for an unrelated
                // group, including when a helper detached from Git's wait.
                // Darwin can report EPERM when the unreaped zombie is the
                // group's sole remaining member. Only the post-reap ESRCH
                // probe below can accept completion in that case.
                if kill(-pid, SIGKILL) != 0 && errno != ESRCH && errno != EPERM { failure = "Git helper cleanup was rejected." }
                let waited = waitpid(pid, &status, WNOHANG)
                if waited == pid { reaped = true }
                else if waited < 0, errno != EINTR { failure = "Git child exit could not be reaped."; break }
            }
            let now = ProcessInfo.processInfo.systemUptime
            if cancellation.isCancelled { failure = "Canceled. Refresh to inspect the repository." }
            if now - began >= seconds { failure = "Git exceeded its \(Int(seconds))-second limit. Refresh to inspect the repository." }
            if failure != nil, terminatedAt == nil { terminatedAt = now }
            if failure != nil, !reaped {
                if !termSent { _ = kill(-pid, SIGTERM); termSent = true }
                else if !killed, now - terminatedAt! >= 0.25 { _ = kill(-pid, SIGKILL); killed = true }
            }
            if reaped && outEOF && errEOF, kill(-pid, 0) != 0, errno == ESRCH { break }
            if now - began >= seconds + 3 || (terminatedAt != nil && now - terminatedAt! >= 3) {
                failure = "Git did not close cleanly within its limit. Refresh to inspect the repository."
                break
            }
            usleep(10_000)
        }
        guard reaped else { throw GitWorkspaceError(message: failure ?? "Git child was not reaped.") }
        if let failure { throw GitWorkspaceError(message: failure) }
        let exitStatus = (status & 0x7f) == 0 ? (status >> 8) & 0xff : 128 + (status & 0x7f)
        return Output(status: exitStatus, stdout: stdout, stderr: stderr)
    }
}

enum GitWorkspaceBackend {
    static func parseStatus(_ data: Data) throws -> [GitWorkspaceChange] {
        if data.isEmpty { return [] }
        guard data.last == 0 else { throw GitWorkspaceError(message: "Git returned a truncated status.") }
        let records = data.split(separator: 0, omittingEmptySubsequences: false).dropLast()
        var index = 0, result: [GitWorkspaceChange] = []
        while index < records.count {
            let bytes = Array(records[index]); index += 1
            guard bytes.count >= 4, bytes[2] == 32,
                  let path = String(bytes: bytes.dropFirst(3), encoding: .utf8), validPath(path) else {
                throw GitWorkspaceError(message: "Git returned an unsupported filename or status.")
            }
            let x = Character(UnicodeScalar(bytes[0])), y = Character(UnicodeScalar(bytes[1]))
            guard " MADRCUT?!".contains(x), " MADRCUT?!".contains(y) else { throw GitWorkspaceError(message: "Unknown Git status.") }
            var old: String?
            if x == "R" || x == "C" || y == "R" || y == "C" {
                guard index < records.count, let name = String(bytes: records[index], encoding: .utf8), validPath(name) else {
                    throw GitWorkspaceError(message: "Git returned a truncated rename.")
                }
                old = name; index += 1
            }
            result.append(.init(path: path, originalPath: old, index: x, worktree: y))
            guard result.count <= 4096 else { throw GitWorkspaceError(message: "This view supports up to 4,096 changed files.") }
        }
        guard Set(result.map(\.path)).count == result.count else { throw GitWorkspaceError(message: "Git returned duplicate changed paths.") }
        return result
    }

    static func validPath(_ path: String) -> Bool {
        let name = path.hasSuffix("/") ? String(path.dropLast()) : path
        return !name.isEmpty && !name.hasPrefix("/") && !name.utf8.contains(0) &&
        !name.split(separator: "/", omittingEmptySubsequences: false).contains(where: { $0 == "." || $0 == ".." || $0 == ".git" || $0.isEmpty })
    }

    /// Gate every command that may inspect working-tree content before it can
    /// run Git's clean conversion. --no-textconv does not disable clean filters.
    private static func readConfiguration(_ root: URL, _ token: GitWorkspaceCancellation) throws -> [(String, String)] {
        let gitDirectory = root.appendingPathComponent(".git", isDirectory: true)
        var info = stat()
        guard lstat(gitDirectory.path, &info) == 0, info.st_mode & S_IFMT == S_IFDIR else {
            throw GitWorkspaceError(message: "Choose a repository with its own .git directory inside the selected folder. Linked worktrees and external Git directories are not supported here.")
        }
        for relative in ["commondir", "objects/info/alternates", "objects/info/http-alternates"] {
            guard lstat(gitDirectory.appendingPathComponent(relative).path, &info) != 0 && errno == ENOENT else {
                throw GitWorkspaceError(message: "Repositories with a shared Git directory or alternate object storage must be opened in your usual Git client.")
            }
        }
        for relative in ["config", "objects", "refs"] {
            let path = gitDirectory.appendingPathComponent(relative).path
            if lstat(path, &info) == 0, info.st_mode & S_IFMT == S_IFLNK {
                throw GitWorkspaceError(message: "Git metadata links outside the selected repository are not supported here.")
            }
        }
        let began = ProcessInfo.processInfo.systemUptime
        var enumerationFailed = false
        guard let entries = FileManager.default.enumerator(at: gitDirectory,
            includingPropertiesForKeys: nil, options: [], errorHandler: { _, _ in enumerationFailed = true; return false }) else {
            throw GitWorkspaceError(message: "Git metadata could not be inspected.")
        }
        var count = 0
        for case let item as URL in entries {
            count += 1
            guard !token.isCancelled else { throw GitWorkspaceError(message: "Canceled.") }
            guard count <= 100_000, item.pathComponents.count - gitDirectory.pathComponents.count <= 64,
                  ProcessInfo.processInfo.systemUptime - began < 20 else {
                throw GitWorkspaceError(message: "Git metadata exceeds this workspace's inspection limit. Use your usual Git client.")
            }
            guard lstat(item.path, &info) == 0, info.st_mode & S_IFMT != S_IFLNK else {
                throw GitWorkspaceError(message: "Git metadata contains a link or changed during inspection. Use your usual Git client.")
            }
        }
        guard !enumerationFailed else { throw GitWorkspaceError(message: "Git metadata could not be completely inspected.") }
        return try readRequiredConfiguration { arguments in
            try GitWorkspaceCommand.run(root: root, arguments: arguments, cancellation: token)
        }
    }

    /// Git evaluates includes and nonempty filter values without returning their
    /// commands or unrelated configuration (credentials, headers, URLs) to us.
    static func readRequiredConfiguration(
        query: ([String]) throws -> GitWorkspaceCommand.Output
    ) throws -> [(String, String)] {
        func read(_ arguments: [String]) throws -> Data {
            let output = try query(["config", "--null", "--includes"] + arguments)
            // A missing match is status 1 with no output. Do not display raw
            // config diagnostics: even a malformed config can contain secrets.
            guard output.stderr.isEmpty,
                  (output.status == 0 && !output.stdout.isEmpty && output.stdout.last == 0)
                    || (output.status == 1 && output.stdout.isEmpty) else {
                throw GitWorkspaceError(message: "Git author and content-filter configuration could not be inspected.")
            }
            return output.stdout
        }
        // In Git's value-pattern syntax, !^$ selects every nonempty value,
        // including newlines. Inspect all occurrences, as the former list did.
        let filters = try read(["--name-only", "--get-regexp", #"^filter\..*\.(clean|process)$"#, "!^$"])
        guard filters.isEmpty else {
            throw GitWorkspaceError(message: "This repository configures external content filters. Status and diffs can execute those filters, so open it in your usual Git client.")
        }
        let authors = try read(["--get-regexp", #"^user\.(name|email)$"#])
        return try authors.split(separator: 0).map { record in
            let separator = record.firstIndex(of: 10) ?? record.endIndex
            let key = String(decoding: record[..<separator], as: UTF8.self).lowercased()
            guard key == "user.name" || key == "user.email" else {
                throw GitWorkspaceError(message: "Git returned unexpected author configuration.")
            }
            let value = separator == record.endIndex ? "" : String(decoding: record[record.index(after: separator)...], as: UTF8.self)
            return (key, value)
        }
    }

    private static func command(_ root: URL, _ args: [String], _ token: GitWorkspaceCancellation,
                                env: [String: String] = [:], accepted: Set<Int32> = [0]) throws -> GitWorkspaceCommand.Output {
        let output = try GitWorkspaceCommand.run(root: root, arguments: args, cancellation: token, environment: env)
        guard accepted.contains(output.status) else {
            let message = String(decoding: output.stderr.prefix(8192), as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            throw GitWorkspaceError(message: message.isEmpty ? "Git exited with status \(output.status)." : message)
        }
        return output
    }

    static func snapshot(root selected: URL, cancellation token: GitWorkspaceCancellation) throws -> GitWorkspaceSnapshot {
        let pairs = try readConfiguration(selected, token)
        let top = try command(selected, ["rev-parse", "--show-toplevel"], token).stdout
        guard top.last == 10, let path = String(data: top.dropLast(), encoding: .utf8) else {
            throw GitWorkspaceError(message: "Select the top folder of a working Git repository.")
        }
        let root = URL(fileURLWithPath: path, isDirectory: true).standardizedFileURL.resolvingSymlinksInPath()
        guard root == selected.standardizedFileURL.resolvingSymlinksInPath() else {
            throw GitWorkspaceError(message: "Select the repository’s top folder: \(root.path)")
        }
        let raw = try command(root, ["status", "--porcelain=v1", "-z", "--untracked-files=all", "--ignore-submodules=all"], token).stdout
        let changes = try parseStatus(raw)
        let headOutput = try command(root, ["rev-parse", "--verify", "--quiet", "HEAD"], token, accepted: [0, 1])
        let head = headOutput.status == 0 ? String(decoding: headOutput.stdout, as: UTF8.self).trimmingCharacters(in: .newlines) : nil
        let branchOutput = try command(root, ["symbolic-ref", "--quiet", "--short", "HEAD"], token, accepted: [0, 1])
        let branch = branchOutput.status == 0 ? String(decoding: branchOutput.stdout, as: UTF8.self).trimmingCharacters(in: .newlines) : "Detached HEAD"
        var history: [GitWorkspaceCommit] = []
        if head != nil {
            let log = try command(root, ["log", "-z", "-n", "50", "--no-show-signature", "--format=%H%x00%an%x00%ad%x00%s", "--date=iso-strict"], token).stdout
            let records = log.split(separator: 0, omittingEmptySubsequences: false)
            guard records.last?.isEmpty == true, (records.count - 1) % 4 == 0 else { throw GitWorkspaceError(message: "Git history could not be decoded.") }
            for offset in stride(from: 0, to: records.count - 1, by: 4) {
                history.append(.init(id: String(decoding: records[offset], as: UTF8.self), author: String(decoding: records[offset + 1], as: UTF8.self), date: String(decoding: records[offset + 2], as: UTF8.self), subject: String(decoding: records[offset + 3], as: UTF8.self)))
            }
        }
        let entries = try command(root, ["ls-files", "--stage", "-z"], token).stdout.split(separator: 0)
        let submodules = entries.contains { $0.starts(with: Data("160000 ".utf8)) } || FileManager.default.fileExists(atPath: root.appendingPathComponent(".gitmodules").path)
        let block = submodules ? "Use your usual Git client for writes in repositories with submodules." : nil
        return .init(root: root, branch: branch, head: head, changes: changes, history: history, writeBlock: block,
            authorName: pairs.last(where: { $0.0 == "user.name" })?.1 ?? "", authorEmail: pairs.last(where: { $0.0 == "user.email" })?.1 ?? "")
    }

    static func diff(root: URL, change: GitWorkspaceChange, staged: Bool,
                     cancellation token: GitWorkspaceCancellation) throws -> String {
        _ = try readConfiguration(root, token)
        guard change.paths.allSatisfy(validPath) else { throw GitWorkspaceError(message: "Invalid changed path.") }
        if change.untracked && !staged {
            let file = root.appendingPathComponent(change.path)
            let fd = open(file.path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW)
            if fd < 0, errno == ELOOP { return "Untracked symbolic link → " + (try FileManager.default.destinationOfSymbolicLink(atPath: file.path)) }
            guard fd >= 0 else { throw GitWorkspaceError(message: "The untracked file could not be read. Refresh the repository.") }
            defer { close(fd) }
            var info = stat()
            guard fstat(fd, &info) == 0, info.st_mode & S_IFMT == S_IFREG, info.st_size <= 262_144 else { return "Preview unavailable: file is not regular or exceeds 256 KiB." }
            var bytes = [UInt8](repeating: 0, count: Int(info.st_size))
            var count = 0
            while count < bytes.count {
                guard !token.isCancelled else { throw GitWorkspaceError(message: "Canceled.") }
                let remaining = bytes.count - count
                let n = bytes.withUnsafeMutableBytes { read(fd, $0.baseAddress!.advanced(by: count), remaining) }
                if n < 0 && errno == EINTR { continue }
                guard n > 0 else { throw GitWorkspaceError(message: "The file changed while being read. Refresh the repository.") }
                count += n
            }
            return String(bytes: bytes, encoding: .utf8).flatMap { $0.utf8.contains(0) ? nil : $0 } ?? "Binary untracked file (\(bytes.count) bytes)."
        }
        let args = ["diff", "--no-ext-diff", "--no-textconv", "--no-color", "--no-renames", "--ignore-submodules=all"] + (staged ? ["--cached"] : []) + ["--"] + change.paths
        return String(decoding: try command(root, args, token).stdout, as: UTF8.self)
    }

    enum Edit: Sendable { case stage(GitWorkspaceChange), unstage(GitWorkspaceChange), commit(String, String, String) }
    static func commitDiff(root: URL, commit: GitWorkspaceCommit,
                           cancellation token: GitWorkspaceCancellation) throws -> String {
        _ = try readConfiguration(root, token)
        guard [40, 64].contains(commit.id.count), commit.id.allSatisfy({ $0.isHexDigit && !$0.isUppercase }) else {
            throw GitWorkspaceError(message: "Invalid commit identity.")
        }
        let args = ["show", "--no-ext-diff", "--no-textconv", "--no-color", "--no-renames", "--format=fuller", "--stat", "--patch", commit.id, "--"]
        return String(decoding: try command(root, args, token).stdout, as: UTF8.self)
    }
    static func edit(root: URL, action: Edit, cancellation token: GitWorkspaceCancellation) throws -> GitWorkspaceSnapshot {
        let current = try snapshot(root: root, cancellation: token)
        if let block = current.writeBlock { throw GitWorkspaceError(message: block) }
        guard !current.changes.contains(where: \.conflicted) else { throw GitWorkspaceError(message: "Resolve merge conflicts in your usual Git client before writing here.") }
        switch action {
        case .stage(let selected), .unstage(let selected):
            guard let change = current.changes.first(where: { $0.path == selected.path }), change == selected else { throw GitWorkspaceError(message: "The selected file changed status. Refresh and review it again.") }
            guard change.paths.allSatisfy(validPath) else { throw GitWorkspaceError(message: "Invalid changed path.") }
            switch action {
            case .stage:
                for path in change.paths {
                    var info = stat()
                    if lstat(root.appendingPathComponent(path).path, &info) == 0, info.st_mode & S_IFMT == S_IFDIR {
                        throw GitWorkspaceError(message: "Stage nested repositories and directories in your usual Git client.")
                    }
                }
                let attributes = try command(root, ["check-attr", "-z", "filter", "--"] + change.paths, token).stdout.split(separator: 0)
                guard attributes.count % 3 == 0 else { throw GitWorkspaceError(message: "Git attributes could not be checked.") }
                for index in stride(from: 2, to: attributes.count, by: 3) {
                    let value = String(decoding: attributes[index], as: UTF8.self)
                    guard ["unspecified", "unset"].contains(value) else { throw GitWorkspaceError(message: "This file uses a content filter. Stage it in your usual Git client.") }
                }
                _ = try command(root, ["add", "--"] + change.paths, token)
            case .unstage:
                _ = try command(root, current.head == nil ? ["rm", "--cached", "--force", "--ignore-unmatch", "--"] + change.paths : ["reset", "--quiet", "HEAD", "--"] + change.paths, token)
            case .commit: break
            }
        case .commit(let message, let name, let email):
            guard current.changes.contains(where: \.staged) else { throw GitWorkspaceError(message: "Stage at least one change before committing.") }
            guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, message.utf8.count <= 16_384, !message.utf8.contains(0),
                  !name.isEmpty, name.utf8.count <= 256, !name.contains(where: { $0.isNewline || $0 == "<" || $0 == ">" || $0.asciiValue == 0 }),
                  email.contains("@"), email.utf8.count <= 256, !email.contains(where: { $0.isWhitespace || $0 == "<" || $0 == ">" || $0.asciiValue == 0 }) else {
                throw GitWorkspaceError(message: "Enter a commit message, author name and valid email.")
            }
            _ = try command(root, ["commit", "--no-gpg-sign", "--no-verify", "-m", message], token,
                env: ["GIT_AUTHOR_NAME": name, "GIT_AUTHOR_EMAIL": email, "GIT_COMMITTER_NAME": name, "GIT_COMMITTER_EMAIL": email])
        }
        return try snapshot(root: root, cancellation: token)
    }
}
