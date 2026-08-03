// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation
import PrimeCore

private enum IntegrationError: Error {
    case rejected(String)
}

@main
private struct PrimeValidationWorkflowSecureChildIntegration {
    static func main() {
        guard #available(macOS 26.0, *) else {
            writeMessage(
                "prime-validation secure-child integration: "
                    + "FAIL macOS_26_required\n",
                descriptor: STDERR_FILENO
            )
            Darwin._exit(2)
        }
        do {
            try run()
            writeMessage(
                "prime-validation secure-child integration: "
                    + "PASS modes=9 logical_argv0=PASS "
                    + "one_shot=PASS "
                    + "executable_replacement=REJECTED\n",
                descriptor: STDOUT_FILENO
            )
        } catch {
            writeMessage(
                "prime-validation secure-child integration: "
                    + "FAIL \(error)\n",
                descriptor: STDERR_FILENO
            )
            Darwin._exit(1)
        }
    }

    @available(macOS 26.0, *)
    private static func run() throws {
        let arguments = Array(CommandLine.arguments.dropFirst())
        guard arguments.count == 1 else {
            throw IntegrationError.rejected(
                "usage_exact_fixture_path"
            )
        }
        let fixtureURL = try canonicalFileURL(arguments[0])
        let root = try makePrivateRoot()
        defer { try? FileManager.default.removeItem(at: root) }

        for mode in PrimeValidationWorkflowFixtureChildMode.allCases {
            let pair = try makeDirectoryPair(
                under: root,
                label: mode.rawValue
            )
            let capability = try
                PrimeValidationWorkflowFixtureChildCapability.prepare(
                    executableURL: fixtureURL,
                    privateWorkingDirectoryURL: pair.working,
                    privateResultDirectoryURL: pair.result,
                    mode: mode
                )
            let result = try capability.execute()
            try require(
                result.mode == mode,
                "mode_round_trip_\(mode.rawValue)"
            )
            try require(
                result.fixtureContractSatisfied,
                "fixture_contract_\(mode.rawValue)"
            )
            try require(
                result.sessionIdentifier == result.processIdentifier
                    && result.processGroupIdentifier
                        == result.processIdentifier,
                "session_or_group_\(mode.rawValue)"
            )
            try require(
                result.workingDirectoryJoin
                    .exactDescriptorJoinObserved
                    && result.mappedExecutable
                        .exactDescriptorJoinObserved,
                "descriptor_join_\(mode.rawValue)"
            )
            try require(
                result.exactPIDWait.returnedProcessIdentifier
                    == result.processIdentifier
                    && result.exactPIDWait.childReaped
                    && result.processGroupEmptyAfterReap,
                "reap_or_containment_\(mode.rawValue)"
            )
            try require(
                result.standardOutput.reachedEOF
                    && result.standardError.reachedEOF,
                "stream_eof_\(mode.rawValue)"
            )
            try validateModeSpecific(result)

            if mode == .pass {
                do {
                    _ = try capability.execute()
                    throw IntegrationError.rejected(
                        "one_shot_reuse_accepted"
                    )
                } catch let error as
                    PrimeValidationWorkflowFixtureChildError
                {
                    guard error
                            == .rejected(
                                "capability_already_consumed"
                            )
                    else { throw error }
                }
            }
        }

        try requireConcurrentOneShotCapability(under: root, fixtureURL: fixtureURL)
        try requireExecutableReplacementRejected(
            pinnedFixtureURL: fixtureURL,
            under: root
        )
    }

    @available(macOS 26.0, *)
    private static func requireConcurrentOneShotCapability(
        under root: URL,
        fixtureURL: URL
    ) throws {
        let pair = try makeDirectoryPair(
            under: root,
            label: "concurrent-one-shot"
        )
        let capability = try
            PrimeValidationWorkflowFixtureChildCapability.prepare(
                executableURL: fixtureURL,
                privateWorkingDirectoryURL: pair.working,
                privateResultDirectoryURL: pair.result,
                mode: .pass
            )
        let outcomes = ConcurrentOutcomeBox()
        let ready = DispatchGroup()
        let finished = DispatchGroup()
        let release = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(
            label: "com.ergentics.prime.validation-one-shot",
            attributes: .concurrent
        )
        for _ in 0 ..< 2 {
            ready.enter()
            finished.enter()
            queue.async {
                ready.leave()
                release.wait()
                defer { finished.leave() }
                do {
                    _ = try capability.execute()
                    outcomes.recordSuccess()
                } catch let error as
                    PrimeValidationWorkflowFixtureChildError
                {
                    outcomes.record(error: error)
                } catch {
                    outcomes.recordUnexpected(String(describing: error))
                }
            }
        }
        try require(
            ready.wait(timeout: .now() + .seconds(3)) == .success,
            "concurrent_one_shot_ready"
        )
        release.signal()
        release.signal()
        try require(
            finished.wait(timeout: .now() + .seconds(15)) == .success,
            "concurrent_one_shot_finished"
        )
        let snapshot = outcomes.snapshot()
        try require(
            snapshot.successCount == 1
                && snapshot.alreadyConsumedCount == 1
                && snapshot.unexpected.isEmpty,
            "concurrent_one_shot_outcomes_\(snapshot)"
        )
    }

    private static func validateModeSpecific(
        _ result: PrimeValidationWorkflowFixtureChildResult
    ) throws {
        switch result.mode {
        case .pass:
            try require(
                result.completion == .exited(status: 0)
                    && result.fixtureResultData != nil,
                "pass_completion"
            )
        case .logicalArgumentZero:
            try require(
                result.completion == .exited(status: 0)
                    && result.fixtureResultData
                        == Data(
                            """
                            schema=prime_validation_workflow_fixture_result_v1
                            mode=logical-argument-zero
                            configured_payload_stdout_bytes=0
                            configured_payload_stderr_bytes=0
                            configured_exit_code=0
                            observed_argument_zero=swift-build

                            """.utf8
                        )
                    && result.mappedExecutable
                        .mappedExecutableAbsolutePath
                        == result.executableAbsolutePath,
                "logical_argument_zero_or_physical_image"
            )
        case .nonzeroExit:
            try require(
                result.completion == .exited(status: 23),
                "nonzero_completion"
            )
        case .boundedStreams:
            try require(
                result.standardOutput.totalByteCount == 4_096
                    && result.standardError.totalByteCount == 2_048
                    && !result.standardOutput.overflowed
                    && !result.standardError.overflowed,
                "bounded_streams"
            )
        case .overflow:
            try require(
                result.standardOutput.totalByteCount == 131_072
                    && result.standardError.totalByteCount == 131_072
                    && result.standardOutput.overflowed
                    && result.standardError.overflowed
                    && result.standardOutput.capturedByteCount == 65_536
                    && result.standardError.capturedByteCount == 65_536,
                "overflow_streams"
            )
        case .hang:
            guard case .wallClockLimit = result.completion else {
                throw IntegrationError.rejected("hang_completion")
            }
            try require(
                result.preReapProcessGroupMembers
                    == [result.processIdentifier],
                "hang_direct_child_membership"
            )
        case .selfSignal:
            try require(
                result.completion
                    == .signaled(
                        signal: SIGTERM,
                        coreDumped: false
                    ),
                "self_signal_completion"
            )
        case .descendantRetainsStreams:
            guard case .streamContainmentLimit = result.completion,
                  let descendant =
                    result.fixtureDescendantProcessIdentifier,
                  let members = result.preReapProcessGroupMembers
            else {
                throw IntegrationError.rejected(
                    "descendant_completion_or_identity"
                )
            }
            try require(
                Set(members)
                    == Set([
                        result.processIdentifier,
                        descendant,
                    ]),
                "descendant_membership"
            )
        case .exitWithoutResult:
            try require(
                result.completion == .exited(status: 0)
                    && result.fixtureResultBinding == nil
                    && result.fixtureResultData == nil,
                "no_result_contract"
            )
        }
    }

    @available(macOS 26.0, *)
    private static func requireExecutableReplacementRejected(
        pinnedFixtureURL: URL,
        under root: URL
    ) throws {
        let executableDirectory = try makeDirectory(
            under: root,
            name: "executable-replacement"
        )
        let copiedExecutable = executableDirectory
            .appendingPathComponent(
                "PrimeValidationWorkflowFixtureChild"
            )
        try FileManager.default.copyItem(
            at: pinnedFixtureURL,
            to: copiedExecutable
        )
        guard chmod(copiedExecutable.path, mode_t(0o755)) == 0 else {
            throw IntegrationError.rejected(
                "copied_fixture_mode_\(errno)"
            )
        }
        let pair = try makeDirectoryPair(
            under: root,
            label: "executable-mutation"
        )
        let capability = try
            PrimeValidationWorkflowFixtureChildCapability.prepare(
                executableURL: copiedExecutable,
                privateWorkingDirectoryURL: pair.working,
                privateResultDirectoryURL: pair.result,
                mode: .pass
            )

        guard Darwin.unlink(copiedExecutable.path) == 0 else {
            throw IntegrationError.rejected(
                "fixture_replacement_unlink_\(errno)"
            )
        }
        let replacement = Darwin.open(
            copiedExecutable.path,
            O_WRONLY | O_CREAT | O_EXCL
                | O_NOFOLLOW | O_CLOEXEC,
            mode_t(0o500)
        )
        guard replacement >= 3 else {
            if replacement >= 0 { Darwin.close(replacement) }
            throw IntegrationError.rejected(
                "fixture_replacement_open_\(errno)"
            )
        }
        do {
            try writeAll(
                Array("mutated\n".utf8),
                descriptor: replacement
            )
            guard fsync(replacement) == 0,
                  fcntl(replacement, F_FULLFSYNC) == 0
            else {
                throw IntegrationError.rejected(
                    "fixture_replacement_sync_\(errno)"
                )
            }
        } catch {
            Darwin.close(replacement)
            throw error
        }
        Darwin.close(replacement)

        do {
            _ = try capability.execute()
            throw IntegrationError.rejected(
                "fixture_replacement_accepted"
            )
        } catch let error as
            PrimeValidationWorkflowFixtureChildError
        {
            try require(
                error == .rejected("executable_metadata"),
                "fixture_replacement_wrong_rejection_\(error)"
            )
            let entries = try FileManager.default
                .contentsOfDirectory(
                    atPath: pair.result.path
                )
            try require(
                entries.isEmpty,
                "fixture_replacement_spawned_or_published"
            )
        }
    }

    private static func makePrivateRoot() throws -> URL {
        var template = Array(
            "/private/tmp/prime-validation-secure-child.XXXXXX".utf8
        ).map(CChar.init)
        template.append(0)
        let created = template.withUnsafeMutableBufferPointer {
            mkdtemp($0.baseAddress)
        }
        guard created != nil else {
            throw IntegrationError.rejected(
                "private_root_create_\(errno)"
            )
        }
        let result = URL(
            fileURLWithPath: String(cString: template),
            isDirectory: true
        )
        guard chmod(result.path, mode_t(0o700)) == 0 else {
            throw IntegrationError.rejected(
                "private_root_mode_\(errno)"
            )
        }
        return result
    }

    private static func makeDirectoryPair(
        under root: URL,
        label: String
    ) throws -> (working: URL, result: URL) {
        (
            try makeDirectory(
                under: root,
                name: "\(label)-working"
            ),
            try makeDirectory(
                under: root,
                name: "\(label)-result"
            )
        )
    }

    private static func makeDirectory(
        under root: URL,
        name: String
    ) throws -> URL {
        let result = root.appendingPathComponent(
            name,
            isDirectory: true
        )
        guard mkdir(result.path, mode_t(0o700)) == 0,
              chmod(result.path, mode_t(0o700)) == 0
        else {
            throw IntegrationError.rejected(
                "private_directory_\(name)_\(errno)"
            )
        }
        return result
    }

    private static func canonicalFileURL(
        _ path: String
    ) throws -> URL {
        var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
        let resolved = path.withCString { input in
            buffer.withUnsafeMutableBufferPointer {
                realpath(input, $0.baseAddress)
            }
        }
        guard resolved != nil else {
            throw IntegrationError.rejected(
                "fixture_realpath_\(errno)"
            )
        }
        return URL(
            fileURLWithPath: String(cString: buffer)
        )
    }

    private static func require(
        _ condition: @autoclosure () -> Bool,
        _ label: String
    ) throws {
        guard condition() else {
            throw IntegrationError.rejected(label)
        }
    }

    private static func writeAll(
        _ bytes: [UInt8],
        descriptor: Int32
    ) throws {
        var offset = 0
        while offset < bytes.count {
            let written = bytes.withUnsafeBytes {
                Darwin.write(
                    descriptor,
                    $0.baseAddress!.advanced(by: offset),
                    $0.count - offset
                )
            }
            if written < 0, errno == EINTR { continue }
            guard written > 0 else {
                throw IntegrationError.rejected(
                    "write_\(errno)"
                )
            }
            offset += written
        }
    }

    private static func writeMessage(
        _ value: String,
        descriptor: Int32
    ) {
        _ = try? writeAll(
            Array(value.utf8),
            descriptor: descriptor
        )
    }
}

private final class ConcurrentOutcomeBox: @unchecked Sendable {
    private let lock = NSLock()
    private var successCount = 0
    private var alreadyConsumedCount = 0
    private var unexpected: [String] = []

    func recordSuccess() {
        lock.withLock { successCount += 1 }
    }

    func record(
        error: PrimeValidationWorkflowFixtureChildError
    ) {
        lock.withLock {
            if error == .rejected("capability_already_consumed") {
                alreadyConsumedCount += 1
            } else {
                unexpected.append(String(describing: error))
            }
        }
    }

    func recordUnexpected(_ value: String) {
        lock.withLock { unexpected.append(value) }
    }

    func snapshot() -> (
        successCount: Int,
        alreadyConsumedCount: Int,
        unexpected: [String]
    ) {
        lock.withLock {
            (successCount, alreadyConsumedCount, unexpected)
        }
    }
}
