// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

/// Typed, operational process evidence. This value is intentionally not
/// serializable; only its bounded diagnostic projection is serializable.
struct PrimeSecureChildProcessEvidenceV1: Equatable, Sendable {
    enum UnavailableReason: String, Equatable, Sendable {
        case notObserved = "not_observed"
        case notApplicable = "not_applicable"
        case unsupportedByCurrentLifecycle =
            "unsupported_by_current_lifecycle"
        case fullStreamNotHashed = "full_stream_not_hashed"
        case leaseNotProvided = "lease_not_provided"
        case containmentUnproved = "containment_unproved"
    }

    enum Observation<Value>: Equatable, Sendable
    where Value: Equatable & Sendable {
        case observed(Value)
        case unavailable(UnavailableReason)

        var observedValue: Value? {
            guard case let .observed(value) = self else { return nil }
            return value
        }

        var unavailableReason: UnavailableReason? {
            guard case let .unavailable(reason) = self else { return nil }
            return reason
        }
    }

    enum Role: String, Equatable, Sendable {
        case validationWorkflowFixture =
            "validation_workflow_fixture"
    }

    enum Phase: String, Equatable, Sendable {
        case prepared
        case spawnedSuspended = "spawned_suspended"
        case identityProved = "identity_proved"
        case resumed
        case deadlineExpired = "deadline_expired"
        case termAttempted = "term_attempted"
        case killAttempted = "kill_attempted"
        case reaped
        case drainsSettled = "drains_settled"
        case complete
        case failed
    }

    enum OperationalCode: String, Equatable, Sendable {
        case success
        case childNonzeroExit = "child_nonzero_exit"
        case childSignal = "child_signal"
        case wallClockLimit = "wall_clock_limit"
        case streamContainmentLimit = "stream_containment_limit"
        case fixtureContractRejected = "fixture_contract_rejected"
        case operationalFailure = "operational_failure"
    }

    struct Spawn: Equatable, Sendable {
        let processIdentifier: Int32
        let spawnReturnCode: Int32
        let appliedFlags: UInt16
        let sessionIdentifier: Int32
        let processGroupIdentifier: Int32
        let suspendedBeforeIdentityProof: Bool
    }

    struct ExecutableIdentity: Equatable, Sendable {
        let deviceID: UInt64
        let inode: UInt64
        let byteCount: UInt64
        let sha256: String
        let ownerUserID: UInt32
        let ownerGroupID: UInt32
        let permissionMode: UInt16
        let linkCount: UInt64
        let modificationTimeSeconds: Int64
        let modificationTimeNanoseconds: Int64
        let statusChangeTimeSeconds: Int64
        let statusChangeTimeNanoseconds: Int64
    }

    struct DirectoryJoin: Equatable, Sendable {
        let descriptorDeviceID: UInt64
        let descriptorInode: UInt64
        let childCurrentDirectoryDeviceID: UInt64
        let childCurrentDirectoryInode: UInt64
        let exactDescriptorJoinObserved: Bool
    }

    struct MappedExecutableJoin: Equatable, Sendable {
        let mappedExecutableAbsolutePath: String
        let queryCount: Int
        let terminalErrno: Int32
        let exactDescriptorJoinObserved: Bool
    }

    struct Deadline: Equatable, Sendable {
        let startUptimeNanoseconds: Observation<UInt64>
        let absoluteUptimeNanoseconds: Observation<UInt64>
        let expiryObservedUptimeNanoseconds: Observation<UInt64>
        let limitReached: Bool
    }

    enum SignalDisposition: String, Equatable, Sendable {
        case delivered
        case suppressedBecauseAlreadyReaped =
            "suppressed_because_already_reaped"
        case failed
    }

    struct SignalAttempt: Equatable, Sendable {
        let signalNumber: Int32
        let orderedOrdinal: Int
        let attemptedAtUptimeNanoseconds: UInt64
        let disposition: SignalDisposition
        let errorNumber: Int32
    }

    enum Completion: Equatable, Sendable {
        case exited(status: Int32)
        case signaled(signal: Int32, coreDumped: Bool)
        case wallClockLimit(exitStatus: Int32, signal: Int32)
        case streamContainmentLimit(exitStatus: Int32, signal: Int32)

        init(_ completion: PrimeSecureChildCompletion) {
            switch completion {
            case let .exited(status):
                self = .exited(status: status)
            case let .signaled(signal, coreDumped):
                self = .signaled(signal: signal, coreDumped: coreDumped)
            case let .wallClockLimit(exitStatus, signal):
                self = .wallClockLimit(
                    exitStatus: exitStatus,
                    signal: signal
                )
            case let .streamContainmentLimit(exitStatus, signal):
                self = .streamContainmentLimit(
                    exitStatus: exitStatus,
                    signal: signal
                )
            }
        }
    }

    struct ExactPIDReap: Equatable, Sendable {
        let requestedProcessIdentifier: Int32
        let returnedProcessIdentifier: Int32
        let waitOptions: Int32
        let rawWaitStatus: Int32
        let exitedNormally: Bool
        let exitStatus: Int32
        let terminationSignal: Int32
        let coreDumped: Bool
        let childTerminationObserved: Bool
        let childReaped: Bool
        let returnedUptimeNanoseconds: UInt64

        var exactRequestedProcessReaped: Bool {
            let derivedSignal = rawWaitStatus & 0x7f
            let derivedExitedNormally = derivedSignal == 0
            let derivedExitStatus = derivedExitedNormally
                ? (rawWaitStatus >> 8) & 0xff
                : -1
            let derivedCoreDumped = rawWaitStatus & 0x80 != 0
            let rawStatusUsesOnlyDarwinWaitBits =
                rawWaitStatus >= 0
                && rawWaitStatus & ~Int32(0xffff) == 0
            let terminalExitEncoding =
                derivedExitedNormally
                && !derivedCoreDumped
            let terminalSignalEncoding =
                derivedSignal > 0
                && derivedSignal < 0x7f
                && rawWaitStatus & 0xff00 == 0
            return requestedProcessIdentifier > 0
                && returnedProcessIdentifier > 0
                && returnedUptimeNanoseconds > 0
                && rawStatusUsesOnlyDarwinWaitBits
                && (terminalExitEncoding || terminalSignalEncoding)
                && (waitOptions
                        == PrimeSecureChildWaitMode
                        .blockingAfterObservedDeath.darwinOptions
                    || waitOptions
                        == PrimeSecureChildWaitMode
                        .nonblockingContainmentProbe.darwinOptions)
                && childTerminationObserved
                && childReaped
                && requestedProcessIdentifier
                    == returnedProcessIdentifier
                && exitedNormally == derivedExitedNormally
                && exitStatus == derivedExitStatus
                && terminationSignal == derivedSignal
                && coreDumped == derivedCoreDumped
        }
    }

    enum StreamTerminalReason: String, Equatable, Sendable {
        case active
        case endOfFile = "end_of_file"
        case readError = "read_error"
        case writeOrFinalizationError =
            "write_or_finalization_error"
        case cleanupStop = "cleanup_stop"
    }

    struct Stream: Equatable, Sendable {
        let capturedPrefix: Data
        let capturedPrefixByteCount: UInt64
        let capturedPrefixSHA256: String
        let observedTotalByteCount: UInt64
        let fullStreamSHA256: Observation<String>
        let overflowed: Bool
        let workerFinished: Bool
        let descriptorsClosed: Bool
        let terminalReason: StreamTerminalReason
        let reachedEOF: Bool
        let readErrorNumber: Int32
        let writeErrorNumber: Int32
        let finalizationErrorNumber: Int32
        let closeErrorNumber: Int32

        init(
            capturedPrefix: Data,
            totalByteCount: UInt64,
            overflowed: Bool,
            workerFinished: Bool,
            descriptorsClosed: Bool,
            terminalReason: StreamTerminalReason,
            reachedEOF: Bool,
            readErrorNumber: Int32,
            writeErrorNumber: Int32,
            finalizationErrorNumber: Int32,
            closeErrorNumber: Int32
        ) {
            self.capturedPrefix = capturedPrefix
            capturedPrefixByteCount = UInt64(capturedPrefix.count)
            capturedPrefixSHA256 = PrimeSHA256.hexDigest(of: capturedPrefix)
            observedTotalByteCount = totalByteCount
            self.overflowed = overflowed
            self.workerFinished = workerFinished
            self.descriptorsClosed = descriptorsClosed
            self.terminalReason = terminalReason
            self.reachedEOF = reachedEOF
            self.readErrorNumber = readErrorNumber
            self.writeErrorNumber = writeErrorNumber
            self.finalizationErrorNumber = finalizationErrorNumber
            self.closeErrorNumber = closeErrorNumber

            let completeFullStream =
                workerFinished
                && descriptorsClosed
                && terminalReason == .endOfFile
                && reachedEOF
                && readErrorNumber == 0
                && writeErrorNumber == 0
                && finalizationErrorNumber == 0
                && closeErrorNumber == 0
                && !overflowed
                && UInt64(capturedPrefix.count) == totalByteCount
            fullStreamSHA256 = completeFullStream
                ? .observed(PrimeSHA256.hexDigest(of: capturedPrefix))
                : .unavailable(.fullStreamNotHashed)
        }

        var settled: Bool {
            workerFinished
                && descriptorsClosed
                && terminalReason != .active
        }

        var terminalSemanticsValid: Bool {
            capturedPrefixByteCount <= observedTotalByteCount
                && (!overflowed
                    || capturedPrefixByteCount < observedTotalByteCount)
                && (terminalReason != .endOfFile
                    || overflowed
                    || capturedPrefixByteCount == observedTotalByteCount)
                && (terminalReason == .endOfFile) == reachedEOF
                && readErrorNumber >= 0
                && writeErrorNumber >= 0
                && finalizationErrorNumber >= 0
                && closeErrorNumber >= 0
                && (terminalReason != .endOfFile
                    || readErrorNumber == 0
                    && writeErrorNumber == 0
                    && finalizationErrorNumber == 0
                    && closeErrorNumber == 0)
                && (terminalReason != .readError
                    || readErrorNumber > 0)
                && (terminalReason != .writeOrFinalizationError
                    || writeErrorNumber > 0
                    || finalizationErrorNumber > 0
                    || closeErrorNumber > 0)
        }
    }

    struct LeaseObservation: Equatable, Sendable {
        let scope: PrimeSecureChildLeaseRetention.Telemetry.Scope
        let advisory: Bool
        let ownerMustRemainLive: Bool
        let childLifetimeContinuityEstablished: Bool
        let mlxDeviceIdentityEstablished: Bool
        let durableEvidenceEstablished: Bool

        init(_ telemetry: PrimeSecureChildLeaseRetention.Telemetry) {
            // The current seam may report only its single frozen advisory
            // scope. It must not promote capability-provided text or future
            // mutable telemetry into continuity, device, or durability proof.
            _ = telemetry
            scope = .cooperatingHostPathLocal
            advisory = true
            ownerMustRemainLive = true
            childLifetimeContinuityEstablished = false
            mlxDeviceIdentityEstablished = false
            durableEvidenceEstablished = false
        }
    }

    let role: Role
    let phase: Phase
    let operationalCode: OperationalCode
    let spawn: Observation<Spawn>
    let executableIdentity: Observation<ExecutableIdentity>
    let workingDirectoryJoin: Observation<DirectoryJoin>
    let mappedExecutableJoin: Observation<MappedExecutableJoin>
    let deadline: Observation<Deadline>
    let completion: Observation<Completion>
    let termAttempt: Observation<SignalAttempt>
    let killAttempt: Observation<SignalAttempt>
    let exactPIDReap: Observation<ExactPIDReap>
    let processGroupEmpty: Observation<Bool>
    let standardOutput: Stream
    let standardError: Stream
    let lease: Observation<LeaseObservation>

    var signalTimelineSemanticsValid: Bool {
        func unavailableReasonIsValid(
            _ reason: UnavailableReason
        ) -> Bool {
            switch reason {
            case .notObserved, .notApplicable,
                 .unsupportedByCurrentLifecycle:
                return true
            case .fullStreamNotHashed, .leaseNotProvided,
                 .containmentUnproved:
                return false
            }
        }

        func attemptIsValid(
            _ attempt: SignalAttempt,
            signalNumber: Int32,
            ordinal: Int
        ) -> Bool {
            guard attempt.signalNumber == signalNumber,
                  attempt.orderedOrdinal == ordinal,
                  attempt.attemptedAtUptimeNanoseconds > 0
            else { return false }
            switch attempt.disposition {
            case .delivered, .suppressedBecauseAlreadyReaped:
                return attempt.errorNumber == 0
            case .failed:
                return attempt.errorNumber > 0
            }
        }

        switch (termAttempt, killAttempt) {
        case let (.unavailable(termReason), .unavailable(killReason)):
            return unavailableReasonIsValid(termReason)
                && unavailableReasonIsValid(killReason)
        case (.unavailable, .observed):
            return false
        case let (.observed(term), .unavailable(reason)):
            return attemptIsValid(term, signalNumber: 15, ordinal: 1)
                && (reason == .unsupportedByCurrentLifecycle
                    || reason == .notApplicable)
        case let (.observed(term), .observed(kill)):
            return attemptIsValid(term, signalNumber: 15, ordinal: 1)
                && attemptIsValid(kill, signalNumber: 9, ordinal: 2)
                && term.attemptedAtUptimeNanoseconds
                    < kill.attemptedAtUptimeNanoseconds
                && (term.disposition
                        != .suppressedBecauseAlreadyReaped
                    || kill.disposition
                        == .suppressedBecauseAlreadyReaped)
        }
    }

    var operationalSemanticsValid: Bool {
        guard completionMatchesExactReap else { return false }
        switch operationalCode {
        case .success:
            guard phase == .complete,
                  case let .observed(.exited(status)) = completion,
                  status == 0,
                  streamsAreOperationallyClean
            else { return false }
            return observedDeadlineLimitReached == false
        case .childNonzeroExit:
            guard phase == .complete,
                  case let .observed(.exited(status)) = completion,
                  status != 0,
                  streamsAreOperationallyClean
            else { return false }
            return observedDeadlineLimitReached == false
        case .childSignal:
            guard phase == .complete,
                  case .observed(.signaled) = completion,
                  streamsAreOperationallyClean
            else { return false }
            return observedDeadlineLimitReached == false
        case .wallClockLimit:
            guard phase == .complete,
                  case .observed(.wallClockLimit) = completion,
                  streamsAreOperationallyClean
            else { return false }
            return observedDeadlineLimitReached == true
        case .streamContainmentLimit:
            guard phase == .complete,
                  case .observed(.streamContainmentLimit) = completion,
                  streamsAreOperationallyClean
            else { return false }
            return observedDeadlineLimitReached == true
        case .fixtureContractRejected, .operationalFailure:
            return phase == .failed
        }
    }

    private var observedDeadlineLimitReached: Bool? {
        guard case let .observed(value) = deadline else { return nil }
        return value.limitReached
    }

    private var completionMatchesExactReap: Bool {
        guard case let .observed(reap) = exactPIDReap else {
            return false
        }
        switch completion {
        case .unavailable:
            return true
        case let .observed(.exited(status)):
            return reap.exitedNormally
                && reap.exitStatus == status
                && reap.terminationSignal == 0
                && !reap.coreDumped
        case let .observed(.signaled(signal, coreDumped)):
            return !reap.exitedNormally
                && reap.exitStatus == -1
                && reap.terminationSignal == signal
                && reap.coreDumped == coreDumped
        case let .observed(.wallClockLimit(exitStatus, signal)),
             let .observed(.streamContainmentLimit(exitStatus, signal)):
            return reap.exitStatus == exitStatus
                && reap.terminationSignal == signal
        }
    }

    var deadlineSemanticsValid: Bool {
        guard case let .observed(value) = deadline else {
            return true
        }

        func positiveObserved(
            _ observation: Observation<UInt64>
        ) -> Bool {
            guard case let .observed(timestamp) = observation else {
                return true
            }
            return timestamp > 0
        }

        guard positiveObserved(value.startUptimeNanoseconds),
              positiveObserved(value.absoluteUptimeNanoseconds),
              positiveObserved(value.expiryObservedUptimeNanoseconds)
        else { return false }

        if case let .observed(start) = value.startUptimeNanoseconds,
           case let .observed(absolute) = value.absoluteUptimeNanoseconds,
           start >= absolute
        {
            return false
        }
        if case let .observed(expiry) =
            value.expiryObservedUptimeNanoseconds
        {
            if !value.limitReached { return false }
            if case let .observed(start) = value.startUptimeNanoseconds,
               expiry < start
            {
                return false
            }
            if case let .observed(absolute) =
                value.absoluteUptimeNanoseconds,
               expiry < absolute
            {
                return false
            }
            if case let .observed(term) = termAttempt,
               term.attemptedAtUptimeNanoseconds < expiry
            {
                return false
            }
            if case let .observed(kill) = killAttempt,
               kill.attemptedAtUptimeNanoseconds < expiry
            {
                return false
            }
        }
        if !value.limitReached,
           termAttempt.observedValue != nil
                || killAttempt.observedValue != nil
        {
            return false
        }
        return true
    }

    private var streamsAreOperationallyClean: Bool {
        func isClean(_ stream: Stream) -> Bool {
            stream.settled
                && stream.terminalReason == .endOfFile
                && stream.reachedEOF
                && stream.readErrorNumber == 0
                && stream.writeErrorNumber == 0
                && stream.finalizationErrorNumber == 0
                && stream.closeErrorNumber == 0
        }
        return isClean(standardOutput) && isClean(standardError)
    }

    /// Compatibility mapping for the closed first-party fixture result. The
    /// legacy lifecycle does not export signal-attempt timestamps, so those
    /// facts remain typed unavailable instead of being inferred.
    static func validationWorkflowFixture(
        result: PrimeValidationWorkflowFixtureChildResult,
        leaseTelemetry: PrimeSecureChildLeaseRetention.Telemetry? = nil
    ) -> PrimeSecureChildProcessEvidenceV1 {
        let deadlineLimitReached: Bool
        switch result.completion {
        case .wallClockLimit, .streamContainmentLimit:
            deadlineLimitReached = true
        case .exited, .signaled:
            deadlineLimitReached = false
        }
        let deadline = Deadline(
            startUptimeNanoseconds: .unavailable(.notObserved),
            absoluteUptimeNanoseconds: .unavailable(.notObserved),
            expiryObservedUptimeNanoseconds:
                deadlineLimitReached
                ? .unavailable(.unsupportedByCurrentLifecycle)
                : .unavailable(.notApplicable),
            limitReached: deadlineLimitReached
        )
        let reap = result.exactPIDWait
        return PrimeSecureChildProcessEvidenceV1(
            role: .validationWorkflowFixture,
            phase: result.fixtureContractSatisfied ? .complete : .failed,
            operationalCode: operationalCode(
                completion: result.completion,
                fixtureContractSatisfied: result.fixtureContractSatisfied
            ),
            spawn: .observed(
                Spawn(
                    processIdentifier: result.processIdentifier,
                    spawnReturnCode: 0,
                    appliedFlags: result.appliedSpawnFlags,
                    sessionIdentifier: result.sessionIdentifier,
                    processGroupIdentifier: result.processGroupIdentifier,
                    suspendedBeforeIdentityProof: true
                )
            ),
            executableIdentity: .observed(
                ExecutableIdentity(result.executable)
            ),
            workingDirectoryJoin: .observed(
                DirectoryJoin(result.workingDirectoryJoin)
            ),
            mappedExecutableJoin: .observed(
                MappedExecutableJoin(result.mappedExecutable)
            ),
            deadline: .observed(deadline),
            completion: .observed(Completion(result.completion)),
            termAttempt: .unavailable(.unsupportedByCurrentLifecycle),
            killAttempt: .unavailable(.unsupportedByCurrentLifecycle),
            exactPIDReap: .observed(
                ExactPIDReap(reap)
            ),
            processGroupEmpty: .observed(
                result.processGroupEmptyAfterReap
            ),
            standardOutput: Stream(result.standardOutput),
            standardError: Stream(result.standardError),
            lease: leaseTelemetry.map {
                .observed(LeaseObservation($0))
            } ?? .unavailable(.leaseNotProvided)
        )
    }

    private static func operationalCode(
        completion: PrimeSecureChildCompletion,
        fixtureContractSatisfied: Bool
    ) -> OperationalCode {
        guard fixtureContractSatisfied else {
            return .fixtureContractRejected
        }
        switch completion {
        case let .exited(status):
            return status == 0 ? .success : .childNonzeroExit
        case .signaled:
            return .childSignal
        case .wallClockLimit:
            return .wallClockLimit
        case .streamContainmentLimit:
            return .streamContainmentLimit
        }
    }
}

private extension PrimeSecureChildProcessEvidenceV1.ExecutableIdentity {
    init(_ value: PrimeSecureChildExecutableObservation) {
        self.init(
            deviceID: value.deviceID,
            inode: value.inode,
            byteCount: value.byteCount,
            sha256: value.sha256,
            ownerUserID: value.ownerUserID,
            ownerGroupID: value.ownerGroupID,
            permissionMode: value.permissionMode,
            linkCount: value.linkCount,
            modificationTimeSeconds: value.modificationTimeSeconds,
            modificationTimeNanoseconds: value.modificationTimeNanoseconds,
            statusChangeTimeSeconds: value.statusChangeTimeSeconds,
            statusChangeTimeNanoseconds: value.statusChangeTimeNanoseconds
        )
    }
}

private extension PrimeSecureChildProcessEvidenceV1.DirectoryJoin {
    init(_ value: PrimeSecureChildDirectoryJoinObservation) {
        self.init(
            descriptorDeviceID: value.descriptorDeviceID,
            descriptorInode: value.descriptorInode,
            childCurrentDirectoryDeviceID:
                value.childCurrentDirectoryDeviceID,
            childCurrentDirectoryInode:
                value.childCurrentDirectoryInode,
            exactDescriptorJoinObserved:
                value.exactDescriptorJoinObserved
        )
    }
}

private extension PrimeSecureChildProcessEvidenceV1.MappedExecutableJoin {
    init(_ value: PrimeSecureChildMappedExecutableObservation) {
        self.init(
            mappedExecutableAbsolutePath:
                value.mappedExecutableAbsolutePath,
            queryCount: value.queryCount,
            terminalErrno: value.terminalErrno,
            exactDescriptorJoinObserved:
                value.exactDescriptorJoinObserved
        )
    }
}

private extension PrimeSecureChildProcessEvidenceV1.ExactPIDReap {
    init(_ value: PrimeNativeNeuralGateExactPIDWaitObservation) {
        self.init(
            requestedProcessIdentifier:
                value.requestedProcessIdentifier,
            returnedProcessIdentifier:
                value.returnedProcessIdentifier,
            waitOptions: value.waitOptions,
            rawWaitStatus: value.rawWaitStatus,
            exitedNormally: value.exitedNormally,
            exitStatus: value.exitStatus,
            terminationSignal: value.terminationSignal,
            coreDumped: value.coreDumped,
            childTerminationObserved:
                value.childTerminationObserved,
            childReaped: value.childReaped,
            returnedUptimeNanoseconds:
                value.returnedMonotonicNanoseconds
        )
    }
}

private extension PrimeSecureChildProcessEvidenceV1.Stream {
    init(_ value: PrimeSecureChildStreamObservation) {
        let terminalReason:
            PrimeSecureChildProcessEvidenceV1.StreamTerminalReason
        if value.readErrorNumber != 0 {
            terminalReason = .readError
        } else if value.writeErrorNumber != 0 {
            terminalReason = .writeOrFinalizationError
        } else if value.reachedEOF {
            terminalReason = .endOfFile
        } else {
            terminalReason = .cleanupStop
        }
        self.init(
            capturedPrefix: value.prefixData,
            totalByteCount: value.totalByteCount,
            overflowed: value.overflowed,
            workerFinished: true,
            descriptorsClosed: true,
            terminalReason: terminalReason,
            reachedEOF: value.reachedEOF,
            readErrorNumber: value.readErrorNumber,
            writeErrorNumber: value.writeErrorNumber,
            finalizationErrorNumber: 0,
            closeErrorNumber: 0
        )
    }
}

/// The sole Codable Layer-A value. It contains only neutral allowlisted
/// diagnostics; it cannot encode raw process IDs, paths, environment, output,
/// private scientific frames, or a scientific success claim.
struct PrimeSecureChildDiagnosticEnvelopeV1:
    Codable,
    Equatable,
    Sendable
{
    struct CompletionProjection: Codable, Equatable, Sendable {
        let kind: String
        let status: Int32?
        let signal: Int32?
        let coreDumped: Bool?

        enum CodingKeys: String, CodingKey {
            case kind
            case status
            case signal
            case coreDumped = "core_dumped"
        }
    }

    struct DeadlineProjection: Codable, Equatable, Sendable {
        let observation: String
        let limitReached: Bool?
        let termAttempt: String
        let killAttempt: String

        enum CodingKeys: String, CodingKey {
            case observation
            case limitReached = "limit_reached"
            case termAttempt = "term_attempt"
            case killAttempt = "kill_attempt"
        }
    }

    struct ContainmentProjection: Codable, Equatable, Sendable {
        let exactPIDReap: String
        let processGroupEmpty: String

        enum CodingKeys: String, CodingKey {
            case exactPIDReap = "exact_pid_reap"
            case processGroupEmpty = "process_group_empty"
        }
    }

    struct StreamProjection: Codable, Equatable, Sendable {
        let capturedPrefixByteCount: UInt64
        let capturedPrefixSHA256: String
        let observedTotalByteCount: UInt64
        let fullStreamSHA256: String
        let overflowed: Bool
        let terminalReason: String
        let reachedEOF: Bool
        let readErrno: Int32
        let writeErrno: Int32
        let finalizationErrno: Int32
        let closeErrno: Int32
        let workerFinished: Bool
        let descriptorsClosed: Bool

        enum CodingKeys: String, CodingKey {
            case capturedPrefixByteCount =
                "captured_prefix_byte_count"
            case capturedPrefixSHA256 = "captured_prefix_sha256"
            case observedTotalByteCount = "observed_total_byte_count"
            case fullStreamSHA256 = "full_stream_sha256"
            case overflowed
            case terminalReason = "terminal_reason"
            case reachedEOF = "reached_eof"
            case readErrno = "read_errno"
            case writeErrno = "write_errno"
            case finalizationErrno = "finalization_errno"
            case closeErrno = "close_errno"
            case workerFinished = "worker_finished"
            case descriptorsClosed = "descriptors_closed"
        }
    }

    struct StreamsProjection: Codable, Equatable, Sendable {
        let standardOutput: StreamProjection
        let standardError: StreamProjection

        enum CodingKeys: String, CodingKey {
            case standardOutput = "standard_output"
            case standardError = "standard_error"
        }
    }

    let schema: String
    let role: String
    let phase: String
    let operationalCode: String
    let completion: CompletionProjection
    let deadline: DeadlineProjection
    let containment: ContainmentProjection
    let streams: StreamsProjection
    let diagnosticChannel: String
    let scientificOutcome: String

    enum CodingKeys: String, CodingKey {
        case schema
        case role
        case phase
        case operationalCode = "operational_code"
        case completion
        case deadline
        case containment
        case streams
        case diagnosticChannel = "diagnostic_channel"
        case scientificOutcome = "scientific_outcome"
    }
}

enum PrimeSecureChildDiagnosticProjection {
    enum ProjectionError: Error, Equatable, Sendable {
        case containmentUnproved
        case drainUnsettled
        case invalidStreamSemantics
        case invalidSignalTimeline
        case invalidDeadlineSemantics
        case invalidOperationalSemantics
        case oversized
        case noncanonical
    }

    static let maximumCanonicalByteCount = 4_096

    static func envelope(
        for evidence: PrimeSecureChildProcessEvidenceV1
    ) throws -> PrimeSecureChildDiagnosticEnvelopeV1 {
        guard case let .observed(reap) = evidence.exactPIDReap,
              reap.exactRequestedProcessReaped,
              case let .observed(groupEmpty) = evidence.processGroupEmpty,
              groupEmpty
        else {
            throw ProjectionError.containmentUnproved
        }
        guard evidence.standardOutput.settled,
              evidence.standardError.settled
        else {
            throw ProjectionError.drainUnsettled
        }
        guard evidence.standardOutput.terminalSemanticsValid,
              evidence.standardError.terminalSemanticsValid
        else {
            throw ProjectionError.invalidStreamSemantics
        }
        guard evidence.signalTimelineSemanticsValid else {
            throw ProjectionError.invalidSignalTimeline
        }
        guard evidence.deadlineSemanticsValid else {
            throw ProjectionError.invalidDeadlineSemantics
        }
        guard evidence.operationalSemanticsValid else {
            throw ProjectionError.invalidOperationalSemantics
        }

        return PrimeSecureChildDiagnosticEnvelopeV1(
            schema: "prime_secure_child_diagnostic_v1",
            role: evidence.role.rawValue,
            phase: evidence.phase.rawValue,
            operationalCode: evidence.operationalCode.rawValue,
            completion: completionProjection(evidence.completion),
            deadline: deadlineProjection(
                evidence.deadline,
                term: evidence.termAttempt,
                kill: evidence.killAttempt
            ),
            containment: .init(
                exactPIDReap: "observed_true",
                processGroupEmpty: "observed_true"
            ),
            streams: .init(
                standardOutput: streamProjection(evidence.standardOutput),
                standardError: streamProjection(evidence.standardError)
            ),
            diagnosticChannel: "neutral_layer_a",
            scientificOutcome: "not_established"
        )
    }

    static func canonicalData(
        for evidence: PrimeSecureChildProcessEvidenceV1
    ) throws -> Data {
        let envelope = try envelope(for: evidence)
        let data = try PrimeCanonicalJSON.encode(envelope)
        guard data.count <= maximumCanonicalByteCount else {
            throw ProjectionError.oversized
        }
        guard !data.contains(0x0a),
              !data.contains(0x0d),
              try PrimeCanonicalJSON.decode(
                PrimeSecureChildDiagnosticEnvelopeV1.self,
                from: data
              ) == envelope
        else {
            throw ProjectionError.noncanonical
        }
        return data
    }

    private static func completionProjection(
        _ observation:
            PrimeSecureChildProcessEvidenceV1
            .Observation<PrimeSecureChildProcessEvidenceV1.Completion>
    ) -> PrimeSecureChildDiagnosticEnvelopeV1.CompletionProjection {
        switch observation {
        case let .unavailable(reason):
            return .init(
                kind: "unavailable_\(reason.rawValue)",
                status: nil,
                signal: nil,
                coreDumped: nil
            )
        case let .observed(completion):
            switch completion {
            case let .exited(status):
                return .init(
                    kind: "exited",
                    status: status,
                    signal: nil,
                    coreDumped: nil
                )
            case let .signaled(signal, coreDumped):
                return .init(
                    kind: "signaled",
                    status: nil,
                    signal: signal,
                    coreDumped: coreDumped
                )
            case let .wallClockLimit(exitStatus, signal):
                return .init(
                    kind: "wall_clock_limit",
                    status: exitStatus,
                    signal: signal,
                    coreDumped: nil
                )
            case let .streamContainmentLimit(exitStatus, signal):
                return .init(
                    kind: "stream_containment_limit",
                    status: exitStatus,
                    signal: signal,
                    coreDumped: nil
                )
            }
        }
    }

    private static func deadlineProjection(
        _ deadline:
            PrimeSecureChildProcessEvidenceV1
            .Observation<PrimeSecureChildProcessEvidenceV1.Deadline>,
        term:
            PrimeSecureChildProcessEvidenceV1
            .Observation<PrimeSecureChildProcessEvidenceV1.SignalAttempt>,
        kill:
            PrimeSecureChildProcessEvidenceV1
            .Observation<PrimeSecureChildProcessEvidenceV1.SignalAttempt>
    ) -> PrimeSecureChildDiagnosticEnvelopeV1.DeadlineProjection {
        let observation: String
        let limitReached: Bool?
        switch deadline {
        case let .observed(value):
            observation = "observed"
            limitReached = value.limitReached
        case let .unavailable(reason):
            observation = "unavailable_\(reason.rawValue)"
            limitReached = nil
        }
        return .init(
            observation: observation,
            limitReached: limitReached,
            termAttempt: signalProjection(term),
            killAttempt: signalProjection(kill)
        )
    }

    private static func signalProjection(
        _ signal:
            PrimeSecureChildProcessEvidenceV1
            .Observation<PrimeSecureChildProcessEvidenceV1.SignalAttempt>
    ) -> String {
        switch signal {
        case let .observed(value):
            return "observed_\(value.disposition.rawValue)"
        case let .unavailable(reason):
            return "unavailable_\(reason.rawValue)"
        }
    }

    private static func streamProjection(
        _ stream: PrimeSecureChildProcessEvidenceV1.Stream
    ) -> PrimeSecureChildDiagnosticEnvelopeV1.StreamProjection {
        let fullStreamSHA256: String
        switch stream.fullStreamSHA256 {
        case let .observed(value):
            fullStreamSHA256 = "observed_\(value)"
        case let .unavailable(reason):
            fullStreamSHA256 = "unavailable_\(reason.rawValue)"
        }
        return .init(
            capturedPrefixByteCount: stream.capturedPrefixByteCount,
            capturedPrefixSHA256: stream.capturedPrefixSHA256,
            observedTotalByteCount: stream.observedTotalByteCount,
            fullStreamSHA256: fullStreamSHA256,
            overflowed: stream.overflowed,
            terminalReason: stream.terminalReason.rawValue,
            reachedEOF: stream.reachedEOF,
            readErrno: stream.readErrorNumber,
            writeErrno: stream.writeErrorNumber,
            finalizationErrno: stream.finalizationErrorNumber,
            closeErrno: stream.closeErrorNumber,
            workerFinished: stream.workerFinished,
            descriptorsClosed: stream.descriptorsClosed
        )
    }
}
