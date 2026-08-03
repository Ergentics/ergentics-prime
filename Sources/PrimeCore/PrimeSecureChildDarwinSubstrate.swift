// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

/// PrimeCore-internal Darwin spawn transport shared by closed capabilities.
///
/// This is only a suspended-spawn and pipe-ownership layer. It does not admit
/// an executable, working directory, argument vector, environment, deadline,
/// lifecycle, or evidence claim. Closed callers must establish and retain
/// those authorities before invoking it and must contain the returned child.
enum PrimeSecureChildDarwinSubstrate {
    enum Rejection: Error, Equatable, Sendable {
        case rejected(String)

        var detail: String {
            switch self {
            case let .rejected(detail):
                detail
            }
        }
    }

    /// Validates only the C `argv[0]` transport invariant. Closed callers
    /// remain responsible for selecting the exact logical personality.
    static func requireArgumentZero(
        _ argumentZero: String
    ) throws {
        guard !argumentZero.isEmpty,
              argumentZero.utf8.count <= 4_096,
              !argumentZero.utf8.contains(0)
        else {
            throw Rejection.rejected(
                "spawn_argument_zero"
            )
        }
    }

    @available(macOS 26.0, *)
    static func spawnSuspended(
        executableAbsolutePath: String,
        argumentZero: String,
        workingDirectoryDescriptor: Int32,
        exactArguments: [String],
        orderedEnvironment: [(String, String)]
    ) throws -> PrimeSecureChildSpawnHandle {
        try requireArgumentZero(argumentZero)

        let stdoutPipe = try RawPipe()
        let stderrPipe: RawPipe
        do {
            stderrPipe = try RawPipe()
        } catch {
            stdoutPipe.closeAll()
            throw error
        }

        do {
            let spawn = try spawnSuspendedChild(
                rootDescriptor:
                    workingDirectoryDescriptor,
                stdoutPipe: stdoutPipe,
                stderrPipe: stderrPipe,
                argumentZero: argumentZero,
                exactArguments: exactArguments,
                orderedEnvironment:
                    orderedEnvironment,
                exactExecutableAbsolutePath:
                    executableAbsolutePath
            )
            stdoutPipe.closeWriteEnd()
            stderrPipe.closeWriteEnd()
            return PrimeSecureChildSpawnHandle(
                processIdentifier:
                    spawn.processIdentifier,
                appliedFlags: spawn.appliedFlags,
                spawnReturnCode:
                    spawn.returnCode,
                spawnReturnedMonotonicNanoseconds:
                    spawn.returnedMonotonicNanoseconds,
                standardOutputReadDescriptor:
                    stdoutPipe.takeReadEnd(),
                standardErrorReadDescriptor:
                    stderrPipe.takeReadEnd(),
                ownsLiveChildObligation: true
            )
        } catch {
            stdoutPipe.closeAll()
            stderrPipe.closeAll()
            throw error
        }
    }

    @available(macOS 26.0, *)
    private static func spawnSuspendedChild(
        rootDescriptor: Int32,
        stdoutPipe: RawPipe,
        stderrPipe: RawPipe,
        argumentZero: String,
        exactArguments: [String],
        orderedEnvironment:
            [(String, String)],
        exactExecutableAbsolutePath: String
    ) throws -> SpawnResult {
        var actions:
            posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        guard posix_spawn_file_actions_init(
            &actions
        ) == 0 else {
            throw rejected(
                "spawn_file_actions_init"
            )
        }
        defer {
            _ = posix_spawn_file_actions_destroy(
                &actions
            )
        }
        guard posix_spawnattr_init(
            &attributes
        ) == 0 else {
            throw rejected("spawn_attributes_init")
        }
        defer {
            _ = posix_spawnattr_destroy(
                &attributes
            )
        }

        try requireSpawnAction(
            posix_spawn_file_actions_addinherit_np(
                &actions,
                rootDescriptor
            ),
            "inherit_root"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addfchdir(
                &actions,
                rootDescriptor
            ),
            "fchdir_root"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addclose(
                &actions,
                rootDescriptor
            ),
            "close_root"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addopen(
                &actions,
                STDIN_FILENO,
                "/dev/null",
                O_RDONLY,
                0
            ),
            "stdin_eof"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addclose(
                &actions,
                stdoutPipe.readDescriptor
            ),
            "close_stdout_read"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_adddup2(
                &actions,
                stdoutPipe.writeDescriptor,
                STDOUT_FILENO
            ),
            "dup_stdout"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addclose(
                &actions,
                stdoutPipe.writeDescriptor
            ),
            "close_stdout_write"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addclose(
                &actions,
                stderrPipe.readDescriptor
            ),
            "close_stderr_read"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_adddup2(
                &actions,
                stderrPipe.writeDescriptor,
                STDERR_FILENO
            ),
            "dup_stderr"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addclose(
                &actions,
                stderrPipe.writeDescriptor
            ),
            "close_stderr_write"
        )

        var defaultSignals = sigset_t()
        guard sigemptyset(&defaultSignals) == 0
        else {
            throw rejected(
                "spawn_default_signals_empty"
            )
        }
        for signal in 1 ..< NSIG
        where signal != SIGKILL
            && signal != SIGSTOP
        {
            guard sigaddset(
                &defaultSignals,
                signal
            ) == 0 else {
                throw rejected(
                    "spawn_default_signal_\(signal)"
                )
            }
        }
        var emptyMask = sigset_t()
        guard sigemptyset(&emptyMask) == 0,
              posix_spawnattr_setsigdefault(
                  &attributes,
                  &defaultSignals
              ) == 0,
              posix_spawnattr_setsigmask(
                  &attributes,
                  &emptyMask
              ) == 0
        else {
            throw rejected(
                "spawn_signal_or_group_policy"
            )
        }

        let flags =
            UInt16(POSIX_SPAWN_START_SUSPENDED)
            | UInt16(
                POSIX_SPAWN_CLOEXEC_DEFAULT
            )
            | UInt16(POSIX_SPAWN_SETSID)
            | UInt16(POSIX_SPAWN_SETSIGDEF)
            | UInt16(POSIX_SPAWN_SETSIGMASK)
        guard flags == 0x448c,
              posix_spawnattr_setflags(
                  &attributes,
                  Int16(bitPattern: flags)
              ) == 0
        else {
            throw rejected("spawn_flags")
        }

        let arguments =
            [argumentZero] + exactArguments
        let duplicatedArguments =
            try duplicateCStringArray(
                arguments
            )
        defer {
            freeCStringArray(
                duplicatedArguments
            )
        }
        var argv =
            duplicatedArguments.map {
                Optional($0)
            }
        argv.append(nil)
        let environmentStrings =
            orderedEnvironment.map {
                "\($0.0)=\($0.1)"
            }
        let duplicatedEnvironment =
            try duplicateCStringArray(
                environmentStrings
            )
        defer {
            freeCStringArray(
                duplicatedEnvironment
            )
        }
        var environment =
            duplicatedEnvironment.map {
                Optional($0)
            }
        environment.append(nil)
        var childPID: pid_t = 0
        let returnCode =
            argv.withUnsafeMutableBufferPointer {
                argvBuffer in
                environment
                    .withUnsafeMutableBufferPointer {
                        environmentBuffer in
                        posix_spawn(
                            &childPID,
                            exactExecutableAbsolutePath,
                            &actions,
                            &attributes,
                            argvBuffer.baseAddress,
                            environmentBuffer
                                .baseAddress
                        )
                    }
            }
        let returnedMonotonicNanoseconds =
            DispatchTime.now().uptimeNanoseconds
        guard returnCode == 0,
              childPID > 0 else {
            throw rejected(
                "posix_spawn_\(returnCode)"
            )
        }
        return SpawnResult(
            processIdentifier: childPID,
            appliedFlags: flags,
            returnCode: returnCode,
            returnedMonotonicNanoseconds:
                returnedMonotonicNanoseconds
        )
    }

    private static func requireSpawnAction(
        _ returnCode: Int32,
        _ label: String
    ) throws {
        guard returnCode == 0 else {
            throw rejected(
                "\(label)_\(returnCode)"
            )
        }
    }

    private static func duplicateCStringArray(
        _ strings: [String]
    ) throws -> [UnsafeMutablePointer<CChar>] {
        var result:
            [UnsafeMutablePointer<CChar>] = []
        result.reserveCapacity(strings.count)
        for string in strings {
            guard !string.contains("\0"),
                  let duplicated =
                    strdup(string) else {
                freeCStringArray(result)
                throw rejected(
                    "argument_encoding"
                )
            }
            result.append(duplicated)
        }
        return result
    }

    private static func freeCStringArray(
        _ strings:
            [UnsafeMutablePointer<CChar>]
    ) {
        for string in strings {
            free(string)
        }
    }

    private static func rejected(
        _ detail: String
    ) -> Rejection {
        .rejected(detail)
    }

    private struct SpawnResult {
        let processIdentifier: Int32
        let appliedFlags: UInt16
        let returnCode: Int32
        let returnedMonotonicNanoseconds:
            UInt64
    }

    private final class RawPipe {
        private(set) var readDescriptor:
            Int32
        private(set) var writeDescriptor:
            Int32

        init() throws {
            var descriptors: [Int32] = [
                -1,
                -1,
            ]
            guard pipe(&descriptors) == 0 else {
                throw rejected(
                    "pipe_\(errno)"
                )
            }
            let normalizedRead =
                fcntl(
                    descriptors[0],
                    F_DUPFD_CLOEXEC,
                    3
                )
            guard normalizedRead >= 3 else {
                let failure = errno
                _ = Darwin.close(
                    descriptors[0]
                )
                _ = Darwin.close(
                    descriptors[1]
                )
                throw rejected(
                    "pipe_read_normalization_\(failure)"
                )
            }
            let normalizedWrite =
                fcntl(
                    descriptors[1],
                    F_DUPFD_CLOEXEC,
                    3
                )
            guard normalizedWrite >= 3,
                  normalizedWrite
                    != normalizedRead else {
                let failure = errno
                _ = Darwin.close(
                    normalizedRead
                )
                _ = Darwin.close(
                    descriptors[0]
                )
                _ = Darwin.close(
                    descriptors[1]
                )
                throw rejected(
                    "pipe_write_normalization_\(failure)"
                )
            }
            _ = Darwin.close(
                descriptors[0]
            )
            _ = Darwin.close(
                descriptors[1]
            )
            readDescriptor =
                normalizedRead
            writeDescriptor =
                normalizedWrite
            do {
                try setCloseOnExec(
                    readDescriptor
                )
                try setCloseOnExec(
                    writeDescriptor
                )
                try setNonBlocking(
                    readDescriptor
                )
            } catch {
                closeAll()
                throw error
            }
        }

        func takeReadEnd() -> Int32 {
            let result = readDescriptor
            readDescriptor = -1
            return result
        }

        func closeWriteEnd() {
            guard writeDescriptor >= 0 else {
                return
            }
            _ = Darwin.close(
                writeDescriptor
            )
            writeDescriptor = -1
        }

        func closeAll() {
            if readDescriptor >= 0 {
                _ = Darwin.close(
                    readDescriptor
                )
                readDescriptor = -1
            }
            closeWriteEnd()
        }

        private func setCloseOnExec(
            _ descriptor: Int32
        ) throws {
            let existing =
                fcntl(
                    descriptor,
                    F_GETFD
                )
            guard existing >= 0,
                  fcntl(
                      descriptor,
                      F_SETFD,
                      existing | FD_CLOEXEC
                  ) == 0
            else {
                throw rejected(
                    "pipe_cloexec_\(errno)"
                )
            }
        }

        private func setNonBlocking(
            _ descriptor: Int32
        ) throws {
            let existing =
                fcntl(
                    descriptor,
                    F_GETFL
                )
            guard existing >= 0,
                  fcntl(
                      descriptor,
                      F_SETFL,
                      existing | O_NONBLOCK
                  ) == 0
            else {
                throw rejected(
                    "pipe_nonblocking_\(errno)"
                )
            }
        }
    }
}

final class PrimeSecureChildSpawnHandle {
    let processIdentifier: Int32
    let appliedFlags: UInt16
    let spawnReturnCode: Int32
    let spawnReturnedMonotonicNanoseconds: UInt64
    private let streamReadDescriptorOwner:
        PrimeSecureChildStreamReadDescriptorOwner
    private let childObligationLock = NSLock()
    private var ownsLiveChildObligation: Bool
    private var dedicatedProcessGroupAuthorityEstablished = false

    init(
        processIdentifier: Int32,
        appliedFlags: UInt16,
        spawnReturnCode: Int32,
        spawnReturnedMonotonicNanoseconds: UInt64,
        standardOutputReadDescriptor: Int32,
        standardErrorReadDescriptor: Int32,
        ownsLiveChildObligation: Bool
    ) {
        self.processIdentifier = processIdentifier
        self.appliedFlags = appliedFlags
        self.spawnReturnCode = spawnReturnCode
        self.spawnReturnedMonotonicNanoseconds =
            spawnReturnedMonotonicNanoseconds
        streamReadDescriptorOwner =
            PrimeSecureChildStreamReadDescriptorOwner(
                standardOutputReadDescriptor:
                    standardOutputReadDescriptor,
                standardErrorReadDescriptor:
                    standardErrorReadDescriptor
            )
        self.ownsLiveChildObligation =
            ownsLiveChildObligation
    }

    /// Transfers both stream descriptors exactly once. The pair is atomic:
    /// no caller can acquire one descriptor while this owner retains the
    /// other. An untransferred pair is closed by `deinit`.
    func takeStreamReadDescriptors()
        -> (standardOutput: Int32, standardError: Int32)
    {
        guard let descriptors =
                streamReadDescriptorOwner
                .takeIfAvailable()
        else {
            failStopOwnedChildIfNeeded()
            Darwin._exit(70)
        }
        return descriptors
    }

    /// Discharges the non-restorable live-child obligation only after the
    /// supervising lifecycle has exact-waited the original PID. Once group
    /// authority was established, that lifecycle also proves the dedicated
    /// process group empty; before proof, the child remained suspended and
    /// containment was exact-PID-only.
    func dischargeChildObligationAfterExactReap() {
        childObligationLock.lock()
        ownsLiveChildObligation = false
        dedicatedProcessGroupAuthorityEstablished = false
        childObligationLock.unlock()
    }

    /// Records that descriptor-rooted supervision has independently proven the
    /// suspended child is both its own session leader and process-group leader.
    /// Before this transition, emergency abandonment may signal only the exact
    /// PID because process-group authority has not yet been established.
    func recordIsolatedSessionAndDedicatedGroupAuthority() {
        childObligationLock.lock()
        if ownsLiveChildObligation {
            dedicatedProcessGroupAuthorityEstablished = true
        }
        childObligationLock.unlock()
    }

    private func failStopOwnedChildIfNeeded() {
        childObligationLock.lock()
        let mustContain = ownsLiveChildObligation
        let maySignalDedicatedProcessGroup =
            dedicatedProcessGroupAuthorityEstablished
        ownsLiveChildObligation = false
        dedicatedProcessGroupAuthorityEstablished = false
        childObligationLock.unlock()
        guard mustContain else {
            return
        }

        if maySignalDedicatedProcessGroup {
            _ = Darwin.kill(
                -processIdentifier,
                SIGKILL
            )
        }
        _ = Darwin.kill(
            processIdentifier,
            SIGKILL
        )
        var status: Int32 = 0
        var returned: Int32
        repeat {
            errno = 0
            returned = Darwin.waitpid(
                processIdentifier,
                &status,
                0
            )
        } while returned < 0 && errno == EINTR
        guard returned == processIdentifier
        else {
            Darwin._exit(70)
        }
        guard maySignalDedicatedProcessGroup
        else {
            return
        }
        errno = 0
        guard Darwin.kill(
            -processIdentifier,
            0
        ) != 0,
        errno == ESRCH
        else {
            Darwin._exit(70)
        }
    }

    deinit {
        childObligationLock.lock()
        let abandoned = ownsLiveChildObligation
        childObligationLock.unlock()
        if abandoned {
            failStopOwnedChildIfNeeded()
            Darwin._exit(70)
        }
    }
}

/// Lock-serialized ownership for the aliased-reference case. The production
/// handle fail-stops if this owner has already transferred its pair; the
/// optional transition is internal so the race invariant can be tested
/// without weakening either closed caller.
final class PrimeSecureChildStreamReadDescriptorOwner {
    private let lock = NSLock()
    private var standardOutputReadDescriptor: Int32
    private var standardErrorReadDescriptor: Int32

    init(
        standardOutputReadDescriptor: Int32,
        standardErrorReadDescriptor: Int32
    ) {
        self.standardOutputReadDescriptor =
            standardOutputReadDescriptor
        self.standardErrorReadDescriptor =
            standardErrorReadDescriptor
    }

    func takeIfAvailable()
        -> (standardOutput: Int32, standardError: Int32)?
    {
        lock.lock()
        defer { lock.unlock() }
        guard standardOutputReadDescriptor >= 0,
              standardErrorReadDescriptor >= 0
        else {
            return nil
        }
        let descriptors = (
            standardOutputReadDescriptor,
            standardErrorReadDescriptor
        )
        standardOutputReadDescriptor = -1
        standardErrorReadDescriptor = -1
        return descriptors
    }

    deinit {
        if standardOutputReadDescriptor >= 0 {
            _ = Darwin.close(
                standardOutputReadDescriptor
            )
        }
        if standardErrorReadDescriptor >= 0 {
            _ = Darwin.close(
                standardErrorReadDescriptor
            )
        }
    }
}
