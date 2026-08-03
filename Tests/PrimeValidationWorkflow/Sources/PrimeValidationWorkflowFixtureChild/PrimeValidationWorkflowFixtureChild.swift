// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation

@_silgen_name("_NSGetEnviron")
private func primeNSGetEnviron()
    -> UnsafeMutablePointer<
        UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
    >

private enum FixtureMode: String, CaseIterable {
    case pass
    case logicalArgumentZero = "logical-argument-zero"
    case nonzeroExit = "nonzero-exit"
    case boundedStreams = "bounded-streams"
    case overflow
    case hang
    case selfSignal = "self-signal"
    case descendantRetainsStreams = "descendant-retains-streams"
    case exitWithoutResult = "exit-without-result"
}

private struct FixtureConfiguration {
    static let maximumStreamBytes = 1_048_576
    static let logicalArgumentZero = "swift-build"

    let mode: FixtureMode
    let resultPath: String?
    let stdoutBytes: Int
    let stderrBytes: Int
    let exitCode: Int32

    static func parse(_ arguments: [String]) throws -> Self {
        guard !arguments.isEmpty,
              arguments.count <= 10,
              arguments.count.isMultiple(of: 2)
        else {
            throw FixtureError.invalidArguments
        }

        var values: [String: String] = [:]
        var index = 0
        while index < arguments.count {
            let key = arguments[index]
            let value = arguments[index + 1]
            guard [
                "--mode",
                "--result-path",
                "--stdout-bytes",
                "--stderr-bytes",
                "--exit-code",
            ].contains(key),
                values.updateValue(value, forKey: key) == nil
            else {
                throw FixtureError.invalidArguments
            }
            index += 2
        }

        guard let rawMode = values["--mode"],
              let mode = FixtureMode(rawValue: rawMode)
        else {
            throw FixtureError.invalidArguments
        }

        let resultPath = values["--result-path"]
        let stdoutBytes = try parseCanonicalInteger(
            values["--stdout-bytes"],
            permitted: 0...maximumStreamBytes
        )
        let stderrBytes = try parseCanonicalInteger(
            values["--stderr-bytes"],
            permitted: 0...maximumStreamBytes
        )
        let parsedExitCode = try parseCanonicalInteger(
            values["--exit-code"],
            permitted: 1...125
        )

        switch mode {
        case .pass, .logicalArgumentZero, .hang, .selfSignal,
            .descendantRetainsStreams:
            guard resultPath != nil,
                  stdoutBytes == nil,
                  stderrBytes == nil,
                  parsedExitCode == nil
            else {
                throw FixtureError.invalidArguments
            }
        case .nonzeroExit:
            guard resultPath != nil,
                  stdoutBytes == nil,
                  stderrBytes == nil,
                  parsedExitCode != nil
            else {
                throw FixtureError.invalidArguments
            }
        case .boundedStreams:
            guard resultPath != nil,
                  stdoutBytes != nil,
                  stderrBytes != nil,
                  parsedExitCode == nil
            else {
                throw FixtureError.invalidArguments
            }
        case .overflow:
            guard resultPath != nil,
                  let stdoutBytes,
                  let stderrBytes,
                  stdoutBytes > 0 || stderrBytes > 0,
                  parsedExitCode == nil
            else {
                throw FixtureError.invalidArguments
            }
        case .exitWithoutResult:
            guard resultPath == nil,
                  stdoutBytes == nil,
                  stderrBytes == nil,
                  parsedExitCode == nil,
                  values.count == 1
            else {
                throw FixtureError.invalidArguments
            }
        }

        if let resultPath {
            try validateAbsoluteResultPath(resultPath)
        }

        return Self(
            mode: mode,
            resultPath: resultPath,
            stdoutBytes: stdoutBytes ?? 0,
            stderrBytes: stderrBytes ?? 0,
            exitCode: Int32(parsedExitCode ?? 0)
        )
    }

    func resultBytes(descendantPID: pid_t? = nil) -> [UInt8] {
        var lines = [
            "schema=prime_validation_workflow_fixture_result_v1",
            "mode=\(mode.rawValue)",
            "configured_payload_stdout_bytes=\(stdoutBytes)",
            "configured_payload_stderr_bytes=\(stderrBytes)",
            "configured_exit_code=\(exitCode)",
        ]
        if mode == .logicalArgumentZero {
            lines.append(
                "observed_argument_zero="
                    + (CommandLine.arguments.first ?? "")
            )
        }
        if let descendantPID {
            lines.append(
                "descendant_pid=\(descendantPID)"
            )
        }
        return Array(
            (lines.joined(separator: "\n") + "\n").utf8
        )
    }

    private static func parseCanonicalInteger(
        _ raw: String?,
        permitted: ClosedRange<Int>
    ) throws -> Int? {
        guard let raw else { return nil }
        guard !raw.isEmpty,
              raw.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }),
              let value = Int(raw),
              String(value) == raw,
              permitted.contains(value)
        else {
            throw FixtureError.invalidArguments
        }
        return value
    }

    private static func validateAbsoluteResultPath(_ path: String) throws {
        guard path.hasPrefix("/"),
              path != "/",
              !path.hasSuffix("/"),
              path.utf8.count <= 4_096,
              path.utf8.allSatisfy({ $0 >= 0x21 && $0 <= 0x7e }),
              !path.contains("\\")
        else {
            throw FixtureError.invalidArguments
        }

        let components = path.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
        guard components.first?.isEmpty == true,
              components.count >= 2,
              components.dropFirst().allSatisfy({
                  !$0.isEmpty && $0 != "." && $0 != ".."
              })
        else {
            throw FixtureError.invalidArguments
        }
    }
}

private enum FixtureError: Error {
    case invalidArguments
    case resultPublicationFailed
}

private enum FixtureExit {
    static let usage: Int32 = 64
    static let operatingSystem: Int32 = 71
    static let inputOutput: Int32 = 74
}

@main
private struct PrimeValidationWorkflowFixtureChild {
    static func main() {
        enterInternalStreamHolderIfRequested()

        let configuration: FixtureConfiguration
        do {
            configuration = try FixtureConfiguration.parse(
                Array(CommandLine.arguments.dropFirst())
            )
        } catch {
            writeDiagnostic(
                "fixture-child: invalid arguments\n"
                    + "usage: PrimeValidationWorkflowFixtureChild "
                    + "--mode <closed-mode> [mode-specific arguments]\n"
            )
            Darwin._exit(FixtureExit.usage)
        }

        guard let physicalExecutable = currentExecutablePath(),
              let observedArgumentZero = CommandLine.arguments.first,
              observedArgumentZero
                == (configuration.mode == .logicalArgumentZero
                    ? FixtureConfiguration.logicalArgumentZero
                    : physicalExecutable)
        else {
            writeDiagnostic(
                "fixture-child: argv0 contract rejected\n"
            )
            Darwin._exit(FixtureExit.usage)
        }

        if configuration.mode == .exitWithoutResult {
            Darwin._exit(0)
        }

        guard let resultPath = configuration.resultPath else {
            Darwin._exit(FixtureExit.usage)
        }
        if configuration.mode == .descendantRetainsStreams {
            runDescendantRetainsStreams(
                configuration: configuration,
                resultPath: resultPath
            )
        }
        do {
            try publishResult(
                configuration.resultBytes(),
                atAbsolutePath: resultPath
            )
        } catch {
            writeDiagnostic("fixture-child: result publication failed\n")
            Darwin._exit(FixtureExit.inputOutput)
        }

        switch configuration.mode {
        case .pass, .logicalArgumentZero:
            Darwin._exit(0)
        case .nonzeroExit:
            Darwin._exit(configuration.exitCode)
        case .boundedStreams, .overflow:
            guard writeRepeatedByte(
                0x4f,
                count: configuration.stdoutBytes,
                descriptor: STDOUT_FILENO
            ),
                writeRepeatedByte(
                    0x45,
                    count: configuration.stderrBytes,
                    descriptor: STDERR_FILENO
                )
            else {
                Darwin._exit(FixtureExit.inputOutput)
            }
            Darwin._exit(0)
        case .hang:
            resetTerminationSignals()
            while true {
                _ = Darwin.pause()
            }
        case .selfSignal:
            resetTerminationSignals()
            guard Darwin.raise(SIGTERM) == 0 else {
                Darwin._exit(FixtureExit.operatingSystem)
            }
            Darwin._exit(FixtureExit.operatingSystem)
        case .descendantRetainsStreams:
            Darwin._exit(FixtureExit.operatingSystem)
        case .exitWithoutResult:
            Darwin._exit(0)
        }
    }

    private static func enterInternalStreamHolderIfRequested() {
        let arguments = Array(CommandLine.arguments.dropFirst())
        guard arguments.first == "--internal-stream-holder" else { return }
        guard arguments.count == 3,
              let expectedParent = canonicalPositivePID(arguments[1]),
              expectedParent == Darwin.getppid(),
              let readinessDescriptor = canonicalPositivePID(arguments[2]),
              readinessDescriptor >= 3,
              Darwin.fcntl(readinessDescriptor, F_GETFD) >= 0
        else {
            writeDiagnostic("fixture-child: invalid internal admission\n")
            Darwin._exit(FixtureExit.usage)
        }
        var ready: UInt8 = 0x52
        let admitted = withUnsafeBytes(of: &ready) {
            writeAll($0, to: readinessDescriptor)
        }
        Darwin.close(readinessDescriptor)
        guard admitted else {
            Darwin._exit(FixtureExit.inputOutput)
        }
        resetTerminationSignals()
        while true {
            _ = Darwin.pause()
        }
    }

    private static func runDescendantRetainsStreams(
        configuration: FixtureConfiguration,
        resultPath: String
    ) -> Never {
        guard let executablePath = currentExecutablePath(),
              let child = spawnStreamHolder(executablePath: executablePath)
        else {
            writeDiagnostic("fixture-child: descendant spawn failed\n")
            Darwin._exit(FixtureExit.operatingSystem)
        }

        do {
            try publishResult(
                configuration.resultBytes(descendantPID: child),
                atAbsolutePath: resultPath
            )
        } catch {
            terminateAndReap(child)
            writeDiagnostic("fixture-child: result publication failed\n")
            Darwin._exit(FixtureExit.inputOutput)
        }

        let announcement = "spawned_descendant_pid=\(child)\n"
        let announced = Array(announcement.utf8).withUnsafeBytes {
            writeAll($0, to: STDOUT_FILENO)
        }
        guard announced else {
            terminateAndReap(child)
            Darwin._exit(FixtureExit.inputOutput)
        }
        Darwin._exit(0)
    }

    private static func currentExecutablePath() -> String? {
        var bytes = [CChar](
            repeating: 0,
            count: 4 * Int(MAXPATHLEN)
        )
        let count = bytes.withUnsafeMutableBytes {
            Darwin.proc_pidpath(
                Darwin.getpid(),
                $0.baseAddress,
                UInt32($0.count)
            )
        }
        guard count > 0,
              count < bytes.count,
              bytes[Int(count)] == 0
        else { return nil }
        return String(cString: bytes)
    }

    private static func spawnStreamHolder(
        executablePath: String
    ) -> pid_t? {
        var readinessPipe = [Int32](repeating: -1, count: 2)
        guard readinessPipe.withUnsafeMutableBufferPointer({
            Darwin.pipe($0.baseAddress)
        }) == 0 else { return nil }
        let readinessRead = readinessPipe[0]
        let readinessWrite = readinessPipe[1]
        guard Darwin.fcntl(readinessRead, F_SETFD, FD_CLOEXEC) == 0,
              Darwin.fcntl(readinessWrite, F_SETFD, 0) == 0
        else {
            Darwin.close(readinessRead)
            Darwin.close(readinessWrite)
            return nil
        }

        let rawArguments = [
            executablePath,
            "--internal-stream-holder",
            String(Darwin.getpid()),
            String(readinessWrite),
        ]
        var ownedArguments = rawArguments.map { Darwin.strdup($0) }
        guard ownedArguments.allSatisfy({ $0 != nil }) else {
            ownedArguments.forEach { Darwin.free($0) }
            Darwin.close(readinessRead)
            Darwin.close(readinessWrite)
            return nil
        }
        defer { ownedArguments.forEach { Darwin.free($0) } }
        ownedArguments.append(nil)

        var child: pid_t = 0
        let result = executablePath.withCString { executable in
            ownedArguments.withUnsafeMutableBufferPointer { arguments in
                Darwin.posix_spawn(
                    &child,
                    executable,
                    nil,
                    nil,
                    arguments.baseAddress,
                    primeNSGetEnviron().pointee
                )
            }
        }
        Darwin.close(readinessWrite)
        guard result == 0, child > 0 else {
            Darwin.close(readinessRead)
            return nil
        }
        guard waitForReadiness(readinessRead) else {
            Darwin.close(readinessRead)
            terminateAndReap(child)
            return nil
        }
        Darwin.close(readinessRead)
        return child
    }

    private static func waitForReadiness(_ descriptor: Int32) -> Bool {
        var observation = pollfd(
            fd: descriptor,
            events: Int16(POLLIN),
            revents: 0
        )
        var pollResult: Int32
        repeat {
            pollResult = Darwin.poll(&observation, 1, 1_000)
        } while pollResult < 0 && errno == EINTR
        guard pollResult == 1,
              observation.revents & Int16(POLLIN) != 0
        else { return false }

        var byte: UInt8 = 0
        var readResult: Int
        repeat {
            readResult = withUnsafeMutableBytes(of: &byte) {
                Darwin.read(descriptor, $0.baseAddress, 1)
            }
        } while readResult < 0 && errno == EINTR
        return readResult == 1 && byte == 0x52
    }

    private static func canonicalPositivePID(_ raw: String) -> pid_t? {
        guard !raw.isEmpty,
              raw.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }),
              let value = Int32(raw),
              value > 0,
              String(value) == raw
        else { return nil }
        return value
    }

    private static func terminateAndReap(_ child: pid_t) {
        _ = Darwin.kill(child, SIGKILL)
        var status: Int32 = 0
        while Darwin.waitpid(child, &status, 0) < 0 && errno == EINTR {}
    }

    private static func resetTerminationSignals() {
        _ = Darwin.signal(SIGTERM, SIG_DFL)
        _ = Darwin.signal(SIGINT, SIG_DFL)
        _ = Darwin.signal(SIGHUP, SIG_DFL)
    }

    private static func writeDiagnostic(_ value: String) {
        _ = Array(value.utf8).withUnsafeBytes { rawBuffer in
            writeAll(rawBuffer, to: STDERR_FILENO)
        }
    }
}

private func publishResult(
    _ bytes: [UInt8],
    atAbsolutePath path: String
) throws {
    let components = path.split(separator: "/").map(String.init)
    guard let leaf = components.last else {
        throw FixtureError.resultPublicationFailed
    }

    var directoryDescriptor = Darwin.open(
        "/",
        O_RDONLY | O_DIRECTORY | O_CLOEXEC
    )
    guard directoryDescriptor >= 0 else {
        throw FixtureError.resultPublicationFailed
    }
    defer { Darwin.close(directoryDescriptor) }

    for component in components.dropLast() {
        let nextDescriptor = component.withCString {
            Darwin.openat(
                directoryDescriptor,
                $0,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard nextDescriptor >= 0 else {
            throw FixtureError.resultPublicationFailed
        }
        Darwin.close(directoryDescriptor)
        directoryDescriptor = nextDescriptor
    }

    let resultDescriptor = leaf.withCString {
        Darwin.openat(
            directoryDescriptor,
            $0,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
    }
    guard resultDescriptor >= 0 else {
        throw FixtureError.resultPublicationFailed
    }

    var publicationSucceeded = false
    defer {
        Darwin.close(resultDescriptor)
        if !publicationSucceeded {
            _ = leaf.withCString {
                Darwin.unlinkat(directoryDescriptor, $0, 0)
            }
        }
    }

    guard Darwin.fchmod(resultDescriptor, S_IRUSR | S_IWUSR) == 0,
          bytes.withUnsafeBytes({ writeAll($0, to: resultDescriptor) }),
          Darwin.fsync(resultDescriptor) == 0
    else {
        throw FixtureError.resultPublicationFailed
    }
    publicationSucceeded = true
}

private func writeRepeatedByte(
    _ byte: UInt8,
    count: Int,
    descriptor: Int32
) -> Bool {
    guard count >= 0 else { return false }
    let chunk = [UInt8](repeating: byte, count: min(count, 4_096))
    var remaining = count
    while remaining > 0 {
        let amount = min(remaining, chunk.count)
        let succeeded = chunk.withUnsafeBytes { buffer -> Bool in
            guard let baseAddress = buffer.baseAddress else { return false }
            return writeAll(
                UnsafeRawBufferPointer(
                    start: baseAddress,
                    count: amount
                ),
                to: descriptor
            )
        }
        guard succeeded else { return false }
        remaining -= amount
    }
    return true
}

private func writeAll(
    _ buffer: UnsafeRawBufferPointer,
    to descriptor: Int32
) -> Bool {
    guard buffer.count == 0 || buffer.baseAddress != nil else { return false }
    var offset = 0
    while offset < buffer.count {
        let result = Darwin.write(
            descriptor,
            buffer.baseAddress!.advanced(by: offset),
            buffer.count - offset
        )
        if result > 0 {
            offset += result
        } else if result < 0 && errno == EINTR {
            continue
        } else {
            return false
        }
    }
    return true
}
