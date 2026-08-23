// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin

private enum PrimeValidationDriverV2SessionFixtureExit {
    static let transport: Int32 = 65
    static let identity: Int32 = 66
    static let spawn: Int32 = 67
    static let childIdentity: Int32 = 68
}

/// XCTest-only conserved-session fixture. The no-argument invocation is its
/// private child state, inferred from the kernel relation instead of a third
/// command mode. Production governor capsules have no fixture selector.
@main
private struct PrimeValidationWorkflowDriverV2SessionFixture {
    private static let prepublicationHeld =
        "--driver-v2-shared-session-prepublication-held"
    private static let orphanTransition =
        "--driver-v2-shared-session-orphan-transition"
    private static let childSpawnFlags: UInt16 = 0x408e

    static func main() {
        let pid = Darwin.getpid()
        let group = Darwin.getpgrp()
        let session = Darwin.getsid(0)

        // A child is spawned with argv[0] only, as a dedicated group inside
        // the fixture supervisor's session. It never spawns or writes.
        if CommandLine.arguments.count == 1,
           pid == group,
           session > 0,
           session != pid
        {
            while true { _ = Darwin.pause() }
        }

        guard CommandLine.arguments.count == 2,
              pid == group,
              pid == session
        else {
            Darwin._exit(PrimeValidationDriverV2SessionFixtureExit.transport)
        }
        let mode = CommandLine.arguments[1]
        guard mode == prepublicationHeld || mode == orphanTransition else {
            Darwin._exit(PrimeValidationDriverV2SessionFixtureExit.transport)
        }
        guard let executable = currentExecutablePath() else {
            Darwin._exit(PrimeValidationDriverV2SessionFixtureExit.identity)
        }

        var attributes: posix_spawnattr_t?
        guard posix_spawnattr_init(&attributes) == 0 else {
            Darwin._exit(PrimeValidationDriverV2SessionFixtureExit.spawn)
        }
        defer { _ = posix_spawnattr_destroy(&attributes) }
        var defaultSignals = sigset_t()
        var emptyMask = sigset_t()
        guard sigemptyset(&defaultSignals) == 0,
              sigemptyset(&emptyMask) == 0
        else {
            Darwin._exit(PrimeValidationDriverV2SessionFixtureExit.spawn)
        }
        for signal in 1 ..< NSIG
        where signal != SIGKILL && signal != SIGSTOP {
            guard sigaddset(&defaultSignals, signal) == 0 else {
                Darwin._exit(PrimeValidationDriverV2SessionFixtureExit.spawn)
            }
        }
        guard posix_spawnattr_setsigdefault(
            &attributes,
            &defaultSignals
        ) == 0,
        posix_spawnattr_setsigmask(&attributes, &emptyMask) == 0,
        posix_spawnattr_setpgroup(&attributes, 0) == 0,
        posix_spawnattr_setflags(
            &attributes,
            Int16(bitPattern: childSpawnFlags)
        ) == 0 else {
            Darwin._exit(PrimeValidationDriverV2SessionFixtureExit.spawn)
        }

        guard let argumentZero = strdup(executable) else {
            Darwin._exit(PrimeValidationDriverV2SessionFixtureExit.spawn)
        }
        defer { free(argumentZero) }
        var arguments: [UnsafeMutablePointer<CChar>?] = [argumentZero, nil]
        var environment: [UnsafeMutablePointer<CChar>?] = [nil]
        var child: pid_t = 0
        let result = arguments.withUnsafeMutableBufferPointer { argv in
            environment.withUnsafeMutableBufferPointer { envp in
                posix_spawn(
                    &child,
                    executable,
                    nil,
                    &attributes,
                    argv.baseAddress!,
                    envp.baseAddress!
                )
            }
        }
        guard result == 0,
              child > 0,
              Darwin.getsid(child) == session,
              Darwin.getpgid(child) == child
        else {
            if child > 0 {
                _ = Darwin.kill(-child, SIGKILL)
                var status: Int32 = 0
                while Darwin.waitpid(child, &status, 0) < 0 && errno == EINTR {}
            }
            Darwin._exit(
                result == 0
                    ? PrimeValidationDriverV2SessionFixtureExit.childIdentity
                    : PrimeValidationDriverV2SessionFixtureExit.spawn
            )
        }

        if mode == orphanTransition {
            Darwin._exit(0)
        }
        while true { _ = Darwin.pause() }
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
              bytes[Int(count)] == 0,
              let value = bytes.withUnsafeBufferPointer({ buffer in
                  buffer.baseAddress.flatMap {
                      String(validatingUTF8: $0)
                  }
              }),
              value.hasPrefix("/")
        else { return nil }
        return value
    }
}
