// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

enum PrimeSecureChildAuthority:
    Equatable,
    Sendable
{
    case directPIDOnly
    case isolatedSessionAndDedicatedGroup
    case dedicatedProcessGroupWithinSupervisorSession(Int32)

    var hasDedicatedProcessGroupAuthority: Bool {
        switch self {
        case .directPIDOnly:
            false
        case .isolatedSessionAndDedicatedGroup,
             .dedicatedProcessGroupWithinSupervisorSession:
            true
        }
    }
}

enum PrimeSecureChildSignal:
    Equatable,
    Sendable
{
    case terminate
    case kill

    var darwinValue: Int32 {
        switch self {
        case .terminate:
            SIGTERM
        case .kill:
            SIGKILL
        }
    }
}

enum PrimeSecureChildSignalTarget:
    Equatable,
    Sendable
{
    case directPID(Int32)
    case processGroup(Int32)
}

enum PrimeSecureChildSignalDelivery:
    Equatable,
    Sendable
{
    case delivered
    case targetAbsent
    case failed(Int32)
}

enum PrimeSecureChildWaitMode:
    Equatable,
    Sendable
{
    case blockingAfterObservedDeath
    case nonblockingContainmentProbe

    var darwinOptions: Int32 {
        switch self {
        case .blockingAfterObservedDeath:
            0
        case .nonblockingContainmentProbe:
            WNOHANG
        }
    }
}

enum PrimeSecureChildWaitResult:
    Equatable,
    Sendable
{
    case stillRunning
    case reaped(
        returnedPID: Int32,
        rawStatus: Int32
    )
    case interrupted
    case failed(Int32)
}

enum PrimeSecureChildContainmentFailureReason:
    String,
    Equatable,
    Sendable
{
    case invalidLifecycleTransition =
        "invalid_lifecycle_transition"
    case terminationSignalFailed =
        "termination_signal_failed"
    case processGroupMembershipUnproven =
        "process_group_membership_unproven"
    case childUncontainedAfterSIGKILL =
        "child_uncontained_after_sigkill"
    case exactPIDWaitFailed =
        "exact_pid_wait_failed"
    case exactPIDWaitReturnedWrongPID =
        "exact_pid_wait_returned_wrong_pid"
    case processGroupNotEmptyAfterReap =
        "process_group_not_empty_after_reap"
    case streamDrainUncontained =
        "stream_drain_uncontained"
}

enum PrimeSecureChildCleanupDisposition:
    Equatable,
    Sendable
{
    case contained
    case mustFailStop(
        PrimeSecureChildContainmentFailureReason
    )
}

enum PrimeSecureChildReapDisposition:
    Equatable,
    Sendable
{
    case reaped(
        PrimeSecureChildExactPIDWaitObservation
    )
    case mustFailStop(
        PrimeSecureChildContainmentFailureReason
    )
}

/// Exact wait result retained by the neutral secure-child lifecycle.
///
/// This type deliberately carries no public neural-gate schema. Closed
/// consumers may project it one way into their existing evidence type.
struct PrimeSecureChildExactPIDWaitObservation:
    Equatable,
    Sendable
{
    let requestedProcessIdentifier: Int32
    let returnedProcessIdentifier: Int32
    let waitOptions: Int32
    let rawWaitStatus: Int32
    let returnedMonotonicNanoseconds: UInt64

    var exitedNormally: Bool {
        rawWaitStatus & 0x7f == 0
    }

    var exitStatus: Int32 {
        exitedNormally
            ? (rawWaitStatus >> 8) & 0xff
            : -1
    }

    var terminationSignal: Int32 {
        rawWaitStatus & 0x7f
    }

    var coreDumped: Bool {
        rawWaitStatus & 0x80 != 0
    }
}

struct PrimeSecureChildLifecycleOperations {
    let startDeathObservation: () -> Void
    let now: () -> UInt64
    let awaitDeathNotification:
        (UInt64) -> UInt64?
    let sendSignal:
        (
            PrimeSecureChildSignalTarget,
            PrimeSecureChildSignal
        ) -> PrimeSecureChildSignalDelivery
    let waitExactPID:
        (PrimeSecureChildWaitMode)
        -> PrimeSecureChildWaitResult
    let processGroupMembers: () -> [Int32]?
    let processGroupIsEmpty: () -> Bool
    let advanceContainmentPoll: () -> Void
    let cancelDeathObservation: () -> Void
}

/// Internal child-state authority shared by the live Darwin factory and
/// deterministic lifecycle tests.
///
/// No operation supplied here is reachable from the public factory surface.
/// Production constructs only `liveDarwin(processIdentifier:)`.
final class PrimeSecureChildLifecycle {
    static let maximumContainmentPollCount =
        200
    static let maximumInterruptedBlockingWaitCount =
        256

    let processIdentifier: Int32
    private let operations:
        PrimeSecureChildLifecycleOperations
    private(set) var authority:
        PrimeSecureChildAuthority =
        .directPIDOnly
    private(set) var resumed = false
    private(set) var hasReaped = false
    private(set) var exactPIDWaitObservation:
        PrimeSecureChildExactPIDWaitObservation?
    private var deathObservedAt: UInt64?
    private var deathObservationStarted =
        false
    private var returnedPIDReapCount = 0
    private var sigkillWasAttempted = false
    private enum CleanupClockState {
        case notStarted
        case tracking(
            cleanupStartedAtUptimeNanoseconds:
                UInt64,
            lastObservedUptimeNanoseconds:
                UInt64
        )
    }
    private var cleanupClockState:
        CleanupClockState = .notStarted

    init(
        processIdentifier: Int32,
        operations:
            PrimeSecureChildLifecycleOperations
    ) {
        precondition(processIdentifier > 0)
        self.processIdentifier =
            processIdentifier
        self.operations = operations
    }

    static func liveDarwin(
        processIdentifier: Int32
    ) -> PrimeSecureChildLifecycle {
        let live =
            PrimeSecureChildLiveDarwinOperations(
                processIdentifier:
                    processIdentifier
            )
        return
            PrimeSecureChildLifecycle(
                processIdentifier:
                    processIdentifier,
                operations:
                    live.operations
            )
    }

    func startDeathObservation() {
        guard !deathObservationStarted,
              !hasReaped
        else {
            return
        }
        deathObservationStarted = true
        operations.startDeathObservation()
    }

    @discardableResult
    func establishIsolatedSessionAndDedicatedGroup()
        -> Bool
    {
        guard authority == .directPIDOnly,
              !resumed,
              !hasReaped
        else {
            return false
        }
        authority =
            .isolatedSessionAndDedicatedGroup
        return true
    }

    @discardableResult
    func establishDedicatedProcessGroupWithinSupervisorSession(
        _ sessionIdentifier: Int32
    ) -> Bool {
        guard authority == .directPIDOnly,
              sessionIdentifier > 0,
              sessionIdentifier != processIdentifier,
              !resumed,
              !hasReaped
        else {
            return false
        }
        authority =
            .dedicatedProcessGroupWithinSupervisorSession(
                sessionIdentifier
            )
        return true
    }

    @discardableResult
    func markResumed() -> Bool {
        guard authority.hasDedicatedProcessGroupAuthority,
              !resumed,
              !hasReaped
        else {
            return false
        }
        resumed = true
        return true
    }

    func observeDeath(
        until deadline: PrimeSecureChildPhaseDeadline
    ) throws -> Bool {
        try observePhaseDeath(
            until: deadline.absolute
        )
    }

    private func observePhaseDeath(
        until deadline:
            PrimeSecureChildAbsoluteDeadline
    ) throws -> Bool {
        if deathObservedAt != nil {
            return true
        }
        guard deathObservationStarted,
              let observed =
                operations
                .awaitDeathNotification(
                    deadline
                    .expiresAtUptimeNanoseconds
                )
        else {
            return false
        }
        guard try deadline
            .isAtOrBeforeExpiration(
                observed
            )
        else {
            return false
        }
        deathObservedAt = observed
        return true
    }

    /// Cleanup accepts a death that predates cleanup start: it is evidence
    /// that the child is already closer to containment, not a phase-success
    /// claim. Only the cleanup endpoint remains authoritative here.
    private func observeCleanupDeath(
        until deadline:
            PrimeSecureChildAbsoluteDeadline
    ) -> Bool {
        if deathObservedAt != nil {
            return true
        }
        guard deathObservationStarted,
              let observed =
                operations
                .awaitDeathNotification(
                    deadline
                    .expiresAtUptimeNanoseconds
                ),
              observed <= deadline
                .expiresAtUptimeNanoseconds
        else {
            return false
        }
        deathObservedAt = observed
        return true
    }

    func deathObservedMonotonicNanoseconds()
        -> UInt64?
    {
        deathObservedAt
    }

    func processGroupMemberIdentifiers()
        -> [Int32]?
    {
        guard authority.hasDedicatedProcessGroupAuthority,
              !hasReaped
        else {
            return nil
        }
        return operations.processGroupMembers()
    }

    func reapAfterObservedDeath()
        -> PrimeSecureChildReapDisposition
    {
        guard deathObservedAt != nil,
              !hasReaped
        else {
            return .mustFailStop(
                .invalidLifecycleTransition
            )
        }
        return reap(
            mode:
                .blockingAfterObservedDeath
        )
    }

    func cleanupTimeline()
        throws -> PrimeSecureChildCleanupTimeline
    {
        let start = operations.now()
        return resumed
            ? try .resumed(
                cleanupStartedAtUptimeNanoseconds:
                    start
            )
            : try .suspended(
                cleanupStartedAtUptimeNanoseconds:
                    start
            )
    }

    /// Last-resort best-effort containment used only when checked cleanup
    /// timeline construction itself is impossible after spawn. Callers must
    /// fail-stop immediately after invoking it; this method never authorizes
    /// an ordinary rejection or success.
    func attemptEmergencySIGKILL() {
        _ = send(.kill)
    }

    func cleanupRejectedCapture(
        using timeline:
            PrimeSecureChildCleanupTimeline
    )
        -> PrimeSecureChildCleanupDisposition
    {
        if hasReaped {
            return .contained
        }
        guard deathObservationStarted else {
            return .mustFailStop(
                .invalidLifecycleTransition
            )
        }

        var signalFailure = false
        switch (resumed, timeline.signalPlan) {
        case let (
            true,
            .resumed(
                terminationDeadline,
                killDeadline
            )
        ):
            if deathObservedAt == nil {
                signalFailure =
                    !send(
                        .terminate
                    )
                _ = observeCleanupDeath(
                    until:
                        terminationDeadline
                )
            }
            if deathObservedAt == nil {
                signalFailure =
                    !send(.kill)
                    || signalFailure
                _ = observeCleanupDeath(
                    until:
                        killDeadline
                )
            }
        case let (
            false,
            .suspended(killDeadline)
        ):
            signalFailure =
                !send(.kill)
            _ = observeCleanupDeath(
                until:
                    killDeadline
            )
        default:
            return .mustFailStop(
                .invalidLifecycleTransition
            )
        }

        if authority.hasDedicatedProcessGroupAuthority {
            let members =
                requireOnlyDirectChildBeforeReap(
                    using: timeline
                )
            guard members else {
                return .mustFailStop(
                    .processGroupMembershipUnproven
                )
            }
        }

        let reapDisposition:
            PrimeSecureChildReapDisposition
        guard cleanupMayContinue(
            using: timeline
        ) else {
            return .mustFailStop(
                .childUncontainedAfterSIGKILL
            )
        }
        if deathObservedAt != nil {
            reapDisposition =
                reap(
                    mode:
                        .blockingAfterObservedDeath
                )
        } else {
            reapDisposition =
                boundedNonblockingReap(
                    using: timeline
                )
        }
        switch reapDisposition {
        case .reaped:
            guard cleanupMayContinue(
                using: timeline
            ) else {
                return .mustFailStop(
                    .childUncontainedAfterSIGKILL
                )
            }
            if signalFailure {
                // A failed delivery is contained only when the exact child was
                // nevertheless reaped and its proven group is empty.
                return .contained
            }
            return .contained
        case let .mustFailStop(reason):
            if signalFailure,
               reason
                == .childUncontainedAfterSIGKILL
            {
                return .mustFailStop(
                    .terminationSignalFailed
                )
            }
            return .mustFailStop(reason)
        }
    }

    private func send(
        _ signal: PrimeSecureChildSignal
    ) -> Bool {
        guard !hasReaped else {
            return false
        }
        if signal == .kill {
            guard !sigkillWasAttempted else {
                return true
            }
            sigkillWasAttempted = true
        }
        let target:
            PrimeSecureChildSignalTarget
        switch authority {
        case .directPIDOnly:
            target =
                .directPID(
                    processIdentifier
                )
        case .isolatedSessionAndDedicatedGroup,
             .dedicatedProcessGroupWithinSupervisorSession:
            target =
                .processGroup(
                    processIdentifier
                )
        }
        switch operations.sendSignal(
            target,
            signal
        ) {
        case .delivered, .targetAbsent:
            return true
        case .failed:
            return false
        }
    }

    private func requireOnlyDirectChildBeforeReap(
        using timeline:
            PrimeSecureChildCleanupTimeline
    )
        -> Bool
    {
        guard authority.hasDedicatedProcessGroupAuthority,
              !hasReaped
        else {
            return false
        }
        guard cleanupMayContinue(
            using: timeline
        ) else {
            return false
        }
        if operations.processGroupMembers()
            == [processIdentifier]
        {
            return true
        }
        _ = send(.kill)
        for _ in
            0 ..< Self.maximumContainmentPollCount
        {
            guard cleanupMayContinue(
                using: timeline
            ) else {
                return false
            }
            operations.advanceContainmentPoll()
            if operations.processGroupMembers()
                == [processIdentifier]
            {
                return true
            }
        }
        return false
    }

    private func boundedNonblockingReap(
        using timeline:
            PrimeSecureChildCleanupTimeline
    )
        -> PrimeSecureChildReapDisposition
    {
        for _ in
            0 ..< Self.maximumContainmentPollCount
        {
            guard cleanupMayContinue(
                using: timeline
            ) else {
                return .mustFailStop(
                    .childUncontainedAfterSIGKILL
                )
            }
            let disposition =
                reap(
                    mode:
                        .nonblockingContainmentProbe
                )
            switch disposition {
            case .reaped:
                return disposition
            case let .mustFailStop(reason):
                if reason
                    != .childUncontainedAfterSIGKILL
                {
                    return disposition
                }
            }
            operations.advanceContainmentPoll()
        }
        return .mustFailStop(
            .childUncontainedAfterSIGKILL
        )
    }

    private func cleanupMayContinue(
        using timeline:
            PrimeSecureChildCleanupTimeline
    ) -> Bool {
        let observed = operations.now()
        do {
            switch cleanupClockState {
            case .notStarted:
                try timeline
                    .requireNonregressingObservation(
                        observed
                    )
            case let .tracking(
                cleanupStartedAt,
                lastObservedAt
            ):
                guard cleanupStartedAt
                        == timeline
                        .cleanupStartedAtUptimeNanoseconds
                else {
                    return false
                }
                try timeline
                    .requireNonregressingObservation(
                        observed,
                        notBefore:
                            lastObservedAt
                    )
            }
        } catch {
            return false
        }
        cleanupClockState = .tracking(
            cleanupStartedAtUptimeNanoseconds:
                timeline
                .cleanupStartedAtUptimeNanoseconds,
            lastObservedUptimeNanoseconds:
                observed
        )
        return observed
            <= timeline
            .containmentDeadline
            .expiresAtUptimeNanoseconds
    }

    private func reap(
        mode: PrimeSecureChildWaitMode
    ) -> PrimeSecureChildReapDisposition {
        guard !hasReaped else {
            return .mustFailStop(
                .invalidLifecycleTransition
            )
        }
        var interruptedCount = 0
        while true {
            switch operations.waitExactPID(
                mode
            ) {
            case .stillRunning:
                return .mustFailStop(
                    .childUncontainedAfterSIGKILL
                )
            case let .reaped(
                returnedPID,
                rawStatus
            ):
                guard returnedPID
                        == processIdentifier
                else {
                    return .mustFailStop(
                        .exactPIDWaitReturnedWrongPID
                    )
                }
                returnedPIDReapCount += 1
                guard returnedPIDReapCount == 1
                else {
                    return .mustFailStop(
                        .invalidLifecycleTransition
                    )
                }
                hasReaped = true
                operations.cancelDeathObservation()
                if authority.hasDedicatedProcessGroupAuthority,
                   !operations
                    .processGroupIsEmpty()
                {
                    return .mustFailStop(
                        .processGroupNotEmptyAfterReap
                    )
                }
                let observation =
                    PrimeSecureChildExactPIDWaitObservation(
                        requestedProcessIdentifier:
                            processIdentifier,
                        returnedProcessIdentifier:
                            returnedPID,
                        waitOptions:
                            mode.darwinOptions,
                        rawWaitStatus:
                            rawStatus,
                        returnedMonotonicNanoseconds:
                            operations.now()
                    )
                exactPIDWaitObservation = observation
                return .reaped(observation)
            case .interrupted:
                interruptedCount += 1
                guard interruptedCount
                        <= Self
                        .maximumInterruptedBlockingWaitCount
                else {
                    return .mustFailStop(
                        .exactPIDWaitFailed
                    )
                }
                if mode
                    == .nonblockingContainmentProbe
                {
                    return .mustFailStop(
                        .childUncontainedAfterSIGKILL
                    )
                }
            case .failed:
                return .mustFailStop(
                    .exactPIDWaitFailed
                )
            }
        }
    }
}

private final class PrimeSecureChildLiveDarwinOperations:
    @unchecked Sendable
{
    let processIdentifier: Int32
    private let lock = NSLock()
    private let deathSemaphore =
        DispatchSemaphore(value: 0)
    private var source:
        DispatchSourceProcess?
    private var deathTimestamp: UInt64?
    private var sourceStarted = false

    init(processIdentifier: Int32) {
        self.processIdentifier =
            processIdentifier
    }

    var operations:
        PrimeSecureChildLifecycleOperations
    {
        PrimeSecureChildLifecycleOperations(
            startDeathObservation: {
                self.startDeathObservation()
            },
            now: {
                DispatchTime.now()
                    .uptimeNanoseconds
            },
            awaitDeathNotification: {
                self.awaitDeath(
                    untilNanoseconds: $0
                )
            },
            sendSignal: {
                self.sendSignal(
                    target: $0,
                    signal: $1
                )
            },
            waitExactPID: {
                self.waitExactPID(mode: $0)
            },
            processGroupMembers: {
                self.processGroupMembers()
            },
            processGroupIsEmpty: {
                self.processGroupIsEmpty()
            },
            advanceContainmentPoll: {
                usleep(10_000)
            },
            cancelDeathObservation: {
                self.cancelDeathObservation()
            }
        )
    }

    private func startDeathObservation() {
        lock.lock()
        guard !sourceStarted else {
            lock.unlock()
            return
        }
        sourceStarted = true
        let created =
            DispatchSource.makeProcessSource(
                identifier:
                    processIdentifier,
                eventMask: .exit,
                queue:
                    DispatchQueue.global(
                        qos: .userInitiated
                    )
            )
        source = created
        lock.unlock()
        created.setEventHandler {
            self.lock.lock()
            if self.deathTimestamp == nil {
                self.deathTimestamp =
                    DispatchTime.now()
                    .uptimeNanoseconds
            }
            self.lock.unlock()
            self.deathSemaphore.signal()
        }
        created.resume()
    }

    private func awaitDeath(
        untilNanoseconds deadline: UInt64
    ) -> UInt64? {
        lock.lock()
        let existing = deathTimestamp
        lock.unlock()
        if let existing {
            return existing
        }
        guard deathSemaphore.wait(
            timeout:
                DispatchTime(
                    uptimeNanoseconds:
                        deadline
                )
        ) == .success
        else {
            return nil
        }
        lock.lock()
        let observed = deathTimestamp
        lock.unlock()
        return observed
    }

    private func sendSignal(
        target: PrimeSecureChildSignalTarget,
        signal: PrimeSecureChildSignal
    ) -> PrimeSecureChildSignalDelivery {
        let identifier: Int32
        switch target {
        case let .directPID(pid):
            identifier = pid
        case let .processGroup(group):
            identifier = -group
        }
        errno = 0
        guard Darwin.kill(
            identifier,
            signal.darwinValue
        ) == 0
        else {
            return errno == ESRCH
                ? .targetAbsent
                : .failed(errno)
        }
        return .delivered
    }

    private func waitExactPID(
        mode: PrimeSecureChildWaitMode
    ) -> PrimeSecureChildWaitResult {
        var status: Int32 = 0
        errno = 0
        let returned =
            Darwin.waitpid(
                processIdentifier,
                &status,
                mode.darwinOptions
            )
        if returned == 0 {
            return .stillRunning
        }
        if returned > 0 {
            return .reaped(
                returnedPID: returned,
                rawStatus: status
            )
        }
        if errno == EINTR {
            return .interrupted
        }
        return .failed(errno)
    }

    private func processGroupMembers()
        -> [Int32]?
    {
        var identifiers = [Int32](
            repeating: 0,
            count: 65_536
        )
        let byteCapacity =
            identifiers.count
            * MemoryLayout<Int32>.size
        errno = 0
        let returnedBytes =
            identifiers
            .withUnsafeMutableBytes {
                proc_listpids(
                    UInt32(PROC_PGRP_ONLY),
                    UInt32(
                        processIdentifier
                    ),
                    $0.baseAddress,
                    Int32($0.count)
                )
            }
        guard returnedBytes > 0,
              Int(returnedBytes)
                < byteCapacity,
              Int(returnedBytes)
                % MemoryLayout<Int32>.size
                == 0
        else {
            return nil
        }
        let count =
            Int(returnedBytes)
            / MemoryLayout<Int32>.size
        let positive =
            identifiers[0 ..< count]
            .filter { $0 > 0 }
        guard Set(positive).count
                == positive.count
        else {
            return nil
        }
        return positive.sorted()
    }

    private func processGroupIsEmpty()
        -> Bool
    {
        errno = 0
        let result =
            Darwin.kill(
                -processIdentifier,
                0
            )
        return result == -1
            && errno == ESRCH
    }

    private func cancelDeathObservation() {
        lock.lock()
        let existing = source
        source = nil
        lock.unlock()
        existing?.cancel()
    }
}
