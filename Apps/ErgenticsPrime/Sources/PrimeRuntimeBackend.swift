import Darwin
import Foundation
import Security

struct PrimeRuntimeFailure: Error, LocalizedError, Sendable {
    let message: String
    var errorDescription: String? { message }
}

final class PrimeRuntimeCancellation: @unchecked Sendable {
    private let lock = NSLock()
    private var requested = false
    func cancel() { lock.lock(); requested = true; lock.unlock() }
    var isCancelled: Bool { lock.lock(); defer { lock.unlock() }; return requested }
}

struct PrimeRuntimeReport: Equatable, Sendable {
    let deviceName: String
    let metallibSHA256: String
    let elapsedSeconds: Double
    let nativeEvidence: Data

    static func decode(_ data: Data, elapsedSeconds: Double) throws -> Self {
        guard data.count <= 262_144,
              let value = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              value["evidence_id"] as? String == "ergentics_prime_native_decoder_maintained_runtime_initialization_v1",
              value["bounded_mlx_runtime_initialization_established"] as? Bool == true,
              value["decoder_forward_observed"] as? Bool == false,
              value["checkpoint_io_observed"] as? Bool == false,
              let synchronization = value["sandbox_application_synchronization_lease"] as? [String: Any],
              synchronization["policy"] as? String == "signed_sandbox_application_internal_synchronization_v1",
              synchronization["applicationIdentifier"] as? String == "com.ergentics.provenance",
              synchronization["helperIdentifier"] as? String == "com.ergentics.provenance.prime-runtime",
              let device = value["metal_device"] as? [String: Any],
              let name = device["index_zero_name"] as? String, !name.isEmpty, name.utf8.count <= 512,
              let library = value["metallib"] as? [String: Any],
              let hash = library["sha256"] as? String, hash.utf8.count == 64,
              hash.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }) else {
            throw PrimeRuntimeFailure(message: "Prime returned an incomplete native runtime result.")
        }
        return Self(deviceName: name, metallibSHA256: hash, elapsedSeconds: elapsedSeconds, nativeEvidence: data)
    }
}

enum PrimeRuntimeBackend {
    static func check(cancellation: PrimeRuntimeCancellation) throws -> PrimeRuntimeReport {
        if cancellation.isCancelled { throw CancellationError() }
        let helper = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/PrimeRuntime/ErgenticsPrimeRuntime")
        try verifyHelper(helper)
        let support = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                                 appropriateFor: nil, create: true)
        let root = try prepareLeaseDirectory(in: support)
        return try run(helper: helper, root: root, cancellation: cancellation)
    }

    static func prepareLeaseDirectory(in support: URL) throws -> URL {
        // Only app synchronization storage belongs here. The sandbox runtime
        // entry validates this fixed location; imported checkpoints and
        // executable resources never use this directory.
        let root = support.appendingPathComponent("PrimeRuntimeSynchronization", isDirectory: true)
        guard mkdir(root.path, 0o700) == 0 || errno == EEXIST else {
            throw PrimeRuntimeFailure(message: "Prime could not create its private runtime storage (\(errno)).")
        }
        let descriptor = open(root.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else {
            throw PrimeRuntimeFailure(message: "Prime runtime storage could not be opened safely (\(errno)).")
        }
        defer { close(descriptor) }
        var opened = stat(), named = stat()
        guard fstat(descriptor, &opened) == 0, lstat(root.path, &named) == 0,
              opened.st_dev == named.st_dev, opened.st_ino == named.st_ino,
              named.st_mode & S_IFMT == S_IFDIR, opened.st_uid == geteuid(),
              opened.st_mode & 0o7777 == 0o700 else {
            throw PrimeRuntimeFailure(message: "Prime runtime storage has an unexpected owner, mode, or identity.")
        }
        // The native lease independently checks ACLs and extended attributes
        // and locks the parent and leaf. Never repair or remove existing data.
        return root
    }

    static func verifyHelper(_ url: URL) throws {
        // Adjacent metallib.json and shader bytes belong to the app's resource
        // seal. Validating only the helper executable would omit those inputs.
        var application: SecStaticCode?
        guard SecStaticCodeCreateWithPath(Bundle.main.bundleURL as CFURL, [], &application) == errSecSuccess,
              let application,
              SecStaticCodeCheckValidity(application, SecCSFlags(rawValue: kSecCSStrictValidate | kSecCSCheckAllArchitectures).union(.noNetworkAccess), nil) == errSecSuccess else {
            throw PrimeRuntimeFailure(message: "The app's bundled Prime resources could not be verified. Rebuild the signed app.")
        }
        var code: SecStaticCode?, requirement: SecRequirement?
        let rule = "anchor apple generic and identifier \"com.ergentics.provenance.prime-runtime\" and certificate leaf[subject.OU] = \"ZCQ435U8JP\""
        guard SecStaticCodeCreateWithPath(url as CFURL, [], &code) == errSecSuccess, let code,
              SecRequirementCreateWithString(rule as CFString, [], &requirement) == errSecSuccess,
              let requirement,
              SecStaticCodeCheckValidity(code, SecCSFlags(rawValue: kSecCSStrictValidate | kSecCSCheckAllArchitectures).union(.noNetworkAccess), requirement) == errSecSuccess else {
            throw PrimeRuntimeFailure(message: "The bundled Prime runtime is missing or its signature could not be verified. Rebuild the app with the Prime runtime target.")
        }
    }

    struct CleanupFailure: Error, LocalizedError, Sendable {
        let detail: String
        var errorDescription: String? {
            "Prime helper cleanup could not be confirmed; further checks are blocked for this app session. \(detail)"
        }
    }

    // A returned error must not let the UI overlap an unconfirmed old child.
    // Tests use a separate admission instance; the app always uses shared.
    final class RunAdmission: @unchecked Sendable {
        struct TerminationAttempt: Equatable, Sendable {
            let target: pid_t
            let result: Int32
            let errorNumber: Int32
        }
        static let shared = RunAdmission()
        private let lock = NSLock()
        private var active = false
        private var blocked = false
        private var attempts: [TerminationAttempt] = []

        // At most one group KILL and one direct-child fallback per run. Retain
        // actual errors even when confirmed cleanup returns cancellation.
        var terminationAttempts: [TerminationAttempt] {
            lock.lock(); defer { lock.unlock() }; return attempts
        }

        fileprivate func recordTermination(target: pid_t, result: Int32, errorNumber: Int32) {
            lock.lock(); defer { lock.unlock() }
            if attempts.count < 2 { attempts.append(.init(target: target, result: result, errorNumber: errorNumber)) }
        }

        func enter() throws {
            lock.lock(); defer { lock.unlock() }
            if blocked { throw CleanupFailure(detail: "An earlier helper did not settle.") }
            guard !active else { throw PrimeRuntimeFailure(message: "Prime is already using the native runtime.") }
            attempts.removeAll(keepingCapacity: true)
            active = true
        }

        func leave(cleanupConfirmed: Bool) {
            lock.lock(); defer { lock.unlock() }
            if !cleanupConfirmed { blocked = true }
            active = false
        }
    }

    // Off-main, fixed argv/environment, with bounded drains and kernel sleeps.
    // Cleanup signals only while this exact direct child remains unreaped.
    static func run(helper: URL, root: URL, cancellation: PrimeRuntimeCancellation,
                    timeoutSeconds: Double = 30, cleanupSeconds: Double = 2,
                    admission: RunAdmission = .shared) throws -> PrimeRuntimeReport {
        if cancellation.isCancelled { throw CancellationError() }
        guard timeoutSeconds.isFinite, timeoutSeconds > 0, timeoutSeconds <= 30,
              cleanupSeconds.isFinite, cleanupSeconds > 0, cleanupSeconds <= 2 else {
            throw PrimeRuntimeFailure(message: "Invalid Prime runtime check bounds.")
        }
        let result = try execute(helper: helper, arguments: ["--check-runtime", root.path],
            root: root, cancellation: cancellation, timeoutSeconds: timeoutSeconds,
            cleanupSeconds: cleanupSeconds, outputLimit: 262_144, admission: admission)
        return try PrimeRuntimeReport.decode(result.standardOutput, elapsedSeconds: result.elapsedSeconds)
    }

    struct ExecutionResult: Sendable {
        let standardOutput: Data
        let standardError: Data
        let elapsedSeconds: Double
        let processIdentifier: pid_t
    }

    // Shared only by the fixed signed-helper adapters below. Successful return
    // still requires exact direct-child reap, both EOFs, and absent owned group.
    static func execute(helper: URL, arguments: [String], root: URL,
                        cancellation: PrimeRuntimeCancellation,
                        timeoutSeconds: Double, cleanupSeconds: Double = 2,
                        outputLimit: Int, admission: RunAdmission = .shared,
                        onOutput: @escaping @Sendable (Data) -> Void = { _ in }) throws -> ExecutionResult {
        if cancellation.isCancelled { throw CancellationError() }
        guard timeoutSeconds.isFinite, timeoutSeconds > 0, timeoutSeconds <= 300,
              cleanupSeconds.isFinite, cleanupSeconds > 0, cleanupSeconds <= 2,
              outputLimit > 0, outputLimit <= 4 * 1024 * 1024,
              arguments.count <= 4, arguments.allSatisfy({ !$0.contains("\0") && $0.utf8.count <= 16_384 }) else {
            throw PrimeRuntimeFailure(message: "Invalid Prime helper bounds or arguments.")
        }
        try admission.enter()
        var cleanupConfirmed = true // No child exists until posix_spawn succeeds.
        defer { admission.leave(cleanupConfirmed: cleanupConfirmed) }
        var output: [Int32] = [-1, -1], error: [Int32] = [-1, -1]
        guard pipe(&output) == 0 else { throw PrimeRuntimeFailure(message: "Could not open Prime output.") }
        defer { output.filter { $0 >= 0 }.forEach { close($0) } }
        guard pipe(&error) == 0 else { throw PrimeRuntimeFailure(message: "Could not open Prime diagnostics.") }
        defer { error.filter { $0 >= 0 }.forEach { close($0) } }
        for fd in output + error {
            guard fcntl(fd, F_SETFD, FD_CLOEXEC) == 0 else {
                throw PrimeRuntimeFailure(message: "Prime pipe setup failed.")
            }
        }
        // Set nonblocking before spawn, so setup errors cannot strand a child.
        for fd in [output[0], error[0]] {
            guard fcntl(fd, F_SETFL, O_NONBLOCK) == 0 else {
                throw PrimeRuntimeFailure(message: "Prime pipe setup failed.")
            }
        }
        var actions: posix_spawn_file_actions_t?, attributes: posix_spawnattr_t?
        guard posix_spawn_file_actions_init(&actions) == 0 else { throw PrimeRuntimeFailure(message: "Prime launch setup failed.") }
        defer { posix_spawn_file_actions_destroy(&actions) }
        guard posix_spawnattr_init(&attributes) == 0 else { throw PrimeRuntimeFailure(message: "Prime launch setup failed.") }
        defer { posix_spawnattr_destroy(&attributes) }
        let setup = [
            posix_spawn_file_actions_addchdir(&actions, root.path),
            posix_spawn_file_actions_addopen(&actions, STDIN_FILENO, "/dev/null", O_RDONLY, 0),
            posix_spawn_file_actions_adddup2(&actions, output[1], STDOUT_FILENO),
            posix_spawn_file_actions_adddup2(&actions, error[1], STDERR_FILENO),
            posix_spawnattr_setflags(&attributes, Int16(POSIX_SPAWN_SETPGROUP | POSIX_SPAWN_CLOEXEC_DEFAULT)),
            posix_spawnattr_setpgroup(&attributes, 0),
        ]
        guard setup.allSatisfy({ $0 == 0 }) else { throw PrimeRuntimeFailure(message: "Prime launch setup was rejected.") }
        var argv: [UnsafeMutablePointer<CChar>?] = ([helper.path] + arguments).map { value in value.withCString { strdup($0) } } + [nil]
        var environment: [UnsafeMutablePointer<CChar>?] = [strdup("MLX_ENABLE_TF32=0"), nil]
        defer { argv.forEach { free($0) }; environment.forEach { free($0) } }
        guard argv.dropLast().allSatisfy({ $0 != nil }), environment[0] != nil else {
            throw PrimeRuntimeFailure(message: "Prime launch allocation failed.")
        }
        if cancellation.isCancelled { throw CancellationError() }
        var pid: pid_t = 0
        let spawned = posix_spawn(&pid, helper.path, &actions, &attributes, &argv, &environment)
        guard spawned == 0 else { throw PrimeRuntimeFailure(message: "Prime could not start (\(spawned)).") }
        cleanupConfirmed = false
        close(output[1]); output[1] = -1; close(error[1]); error[1] = -1
        let start = ProcessInfo.processInfo.systemUptime
        var stdout = Data(), stderr = Data(), stdoutEOF = false, stderrEOF = false
        let groupOwned = getpgid(pid) == pid
        var failure: String? = groupOwned ? nil : "Prime's child process group could not be joined."
        var cleanupDeadline: Double?, signalAttempted = false, reaped = false, status: Int32 = 0
        var ordinaryDrainUntil: Double?
        var waitOwnershipLost = false, groupAbsent = false, readFailed = false
        var signalFailure: String?
        func fail(_ message: String) { if failure == nil { failure = message } }
        func terminate(_ target: pid_t) -> Int32 {
            let result = kill(target, SIGKILL)
            let code = result == 0 ? 0 : errno
            admission.recordTermination(target: target, result: result, errorNumber: code)
            errno = code
            return result
        }
        func drain(_ fd: Int32, data: inout Data, eof: inout Bool, limit: Int, observe: Bool = false) {
            var bytes = [UInt8](repeating: 0, count: 8192)
            for _ in 0..<4 where !eof {
                let count = read(fd, &bytes, bytes.count)
                if count == 0 { eof = true; return }
                if count < 0 {
                    if errno == EINTR { continue }
                    if errno != EAGAIN && errno != EWOULDBLOCK {
                        fail("Prime output could not be read (\(errno)).")
                        readFailed = true
                    }
                    return
                }
                guard data.count + count <= limit else { fail("Prime exceeded its output limit."); return }
                data.append(contentsOf: bytes.prefix(count))
                if observe { onOutput(Data(bytes.prefix(count))) }
            }
        }
        while true {
            drain(output[0], data: &stdout, eof: &stdoutEOF, limit: outputLimit, observe: true)
            drain(error[0], data: &stderr, eof: &stderrEOF, limit: 16_384)
            let now = ProcessInfo.processInfo.systemUptime
            if cancellation.isCancelled { fail("Cancelled.") }
            if now - start >= timeoutSeconds {
                fail(arguments.first == "--generate" ? "Prime exceeded its generation limit." : "Prime exceeded its runtime check limit.")
            }
            var deathObserved = false
            if !reaped && !waitOwnershipLost {
                var info = siginfo_t()
                let observed = waitid(P_PID, id_t(pid), &info, WEXITED | WNOHANG | WNOWAIT)
                deathObserved = observed == 0 && info.si_pid == pid
                if observed < 0 && errno != EINTR {
                    let code = errno
                    fail("Prime child exit could not be observed (\(code)).")
                    // ECHILD means we can no longer rely on unreaped-child ownership.
                    if code == ECHILD { waitOwnershipLost = true }
                }
            }
            if cleanupDeadline == nil && (failure != nil || deathObserved) {
                cleanupDeadline = now + cleanupSeconds
                ordinaryDrainUntil = now + min(0.1, cleanupSeconds / 2)
            }
            // A normal exited helper needs no signal. Drain its bounded tail
            // before deciding whether an inherited pipe still requires cleanup.
            if deathObserved {
                drain(output[0], data: &stdout, eof: &stdoutEOF, limit: outputLimit, observe: true)
                drain(error[0], data: &stderr, eof: &stderrEOF, limit: 16_384)
            }
            let needsTermination = (!deathObserved && failure != nil) ||
                (deathObserved && !(stdoutEOF && stderrEOF) &&
                 (failure != nil || now >= (ordinaryDrainUntil ?? now)))
            if needsTermination && !signalAttempted && !reaped && !waitOwnershipLost {
                signalAttempted = true
                // Retaining the unreaped leader prevents its PID/group ID reuse.
                // A successful signal is not evidence that the group is empty.
                if groupOwned {
                    if terminate(-pid) != 0 && errno != ESRCH {
                        let code = errno
                        signalFailure = "Prime process-group termination failed (\(code))."
                        fail(signalFailure!)
                        if !deathObserved && terminate(pid) != 0 && errno != ESRCH {
                            signalFailure! += " Direct-child termination also failed (\(errno))."
                        }
                    }
                } else if terminate(pid) != 0 && errno != ESRCH {
                    signalFailure = "Prime direct-child termination failed (\(errno))."
                    fail(signalFailure!)
                }
            }
            if deathObserved && (signalAttempted || (stdoutEOF && stderrEOF)) && !reaped && !waitOwnershipLost {
                let waited = waitpid(pid, &status, WNOHANG)
                if waited == pid { reaped = true }
                else if waited < 0 && errno != EINTR {
                    let code = errno
                    fail("Prime child could not be reaped (\(code)).")
                    if code == ECHILD { waitOwnershipLost = true }
                }
            }
            if reaped && groupOwned && !groupAbsent {
                // Read-only observation after reap: never signal a recycled ID.
                let present = kill(-pid, 0)
                groupAbsent = present == -1 && errno == ESRCH
            }
            cleanupConfirmed = reaped && groupOwned && groupAbsent && stdoutEOF && stderrEOF && !readFailed
            if cleanupConfirmed { break }
            let afterWork = ProcessInfo.processInfo.systemUptime
            if let cleanupDeadline, afterWork >= cleanupDeadline { break }
            let nextDeadline = cleanupDeadline ?? (start + timeoutSeconds)
            let milliseconds = Int32(max(0, min(50, ceil((nextDeadline - afterWork) * 1000))))
            var descriptors = [pollfd(fd: stdoutEOF ? -1 : output[0], events: Int16(POLLIN), revents: 0), pollfd(fd: stderrEOF ? -1 : error[0], events: Int16(POLLIN), revents: 0)]
            if poll(&descriptors, 2, milliseconds) < 0 && errno != EINTR {
                fail("Prime output polling failed (\(errno)).")
            }
        }
        guard cleanupConfirmed else {
            throw CleanupFailure(detail: "exact child reaped=\(reaped), original group observed absent=\(groupAbsent), stdout EOF=\(stdoutEOF), stderr EOF=\(stderrEOF). \(signalFailure ?? failure ?? "Cleanup deadline expired.")")
        }
        if cancellation.isCancelled { throw CancellationError() }
        if let failure {
            let diagnostic = signalFailure.flatMap { $0 == failure ? nil : $0 }
            throw PrimeRuntimeFailure(message: failure + (diagnostic.map { " \($0)" } ?? ""))
        }
        guard status == 0, stdoutEOF, stderrEOF else {
            let detail = String(decoding: stderr.prefix(4096), as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            let reason = status & 0x7f == 0 ? "exit code \((status >> 8) & 0xff)" : "signal \(status & 0x7f)"
            let operation = arguments.first == "--generate" ? "generation" : "runtime check"
            throw PrimeRuntimeFailure(message: detail.isEmpty ? "Prime stopped before completing its \(operation) (\(reason))." : detail)
        }
        return ExecutionResult(standardOutput: stdout, standardError: stderr,
            elapsedSeconds: ProcessInfo.processInfo.systemUptime - start, processIdentifier: pid)
    }
}
