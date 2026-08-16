// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

enum PrimeSecureChildResumeDisposition:
    Equatable,
    Sendable
{
    case resumed(
        deliveredAtUptimeNanoseconds: UInt64
    )
    case deadlineExpired
    case signalFailed(Int32)
    case stateRejected
}

enum PrimeSecureChildDrainEvidence {
    case memory(
        standardOutput:
            PrimeSecureChildMemoryDrainSnapshot,
        standardError:
            PrimeSecureChildMemoryDrainSnapshot
    )
    case fileBacked(
        standardOutput:
            PrimeSecureChildFileBackedDrainSnapshot,
        standardError:
            PrimeSecureChildFileBackedDrainSnapshot
    )
}

enum PrimeSecureChildPhaseDrainDisposition {
    case completed(
        PrimeSecureChildDrainEvidence
    )
    case deadlineExpired
    case stateRejected
}

enum PrimeSecureChildDeathObservationDisposition:
    Equatable,
    Sendable
{
    case observed
    case deadlineExpired
    case stateRejected
}

/// Single-owner supervision for one suspended secure child and both of its
/// output drains.
///
/// Adoption consumes the spawn handle's paired stream descriptors exactly
/// once. Every operation after adoption remains under one phase deadline and
/// one lifecycle. Rejection cleanup creates at most one cleanup-only timeline
/// and shares it across child containment and both drains; it never grants
/// phase success.
///
/// This capability is deliberately not `Sendable`. Its signal, wait, reap,
/// and cleanup transitions form one serial ownership history.
final class PrimeSecureChildSupervisionCapability {
    private enum DrainOwnership {
        case memory(
            standardOutput:
                PrimeSecureChildMemoryBoundedDrain,
            standardError:
                PrimeSecureChildMemoryBoundedDrain
        )
        case fileBacked(
            standardOutput:
                PrimeSecureChildFileBackedBoundedDrain,
            standardError:
                PrimeSecureChildFileBackedBoundedDrain
        )
    }

    private enum ExecutionState {
        case suspended
        case resumed
        case reaped
        case cleanupRequired(
            PrimeSecureChildContainmentFailureReason
        )
    }

    private enum CleanupState {
        case notStarted
        case running(
            PrimeSecureChildCleanupTimeline
        )
        case completed(
            PrimeSecureChildCleanupDisposition
        )
    }

    private enum FailureAuthority {
        case none
        case mustFailStop(
            PrimeSecureChildContainmentFailureReason
        )

        func preservingFirst(
            _ reason:
                PrimeSecureChildContainmentFailureReason
        ) -> Self {
            switch self {
            case .none:
                return .mustFailStop(reason)
            case .mustFailStop:
                return self
            }
        }
    }

    let phaseDeadline:
        PrimeSecureChildPhaseDeadline
    private let spawn:
        PrimeSecureChildSpawnHandle
    private let lifecycle:
        PrimeSecureChildLifecycle
    private let drains: DrainOwnership
    private let drainGroup:
        DispatchGroup
    private var executionState:
        ExecutionState = .suspended
    private var cleanupState:
        CleanupState = .notStarted
    private var retainedCleanupTimeline:
        PrimeSecureChildCleanupTimeline? = nil

    private init(
        spawn: PrimeSecureChildSpawnHandle,
        phaseDeadline:
            PrimeSecureChildPhaseDeadline,
        lifecycle:
            PrimeSecureChildLifecycle,
        drains: DrainOwnership,
        drainGroup: DispatchGroup
    ) {
        self.spawn = spawn
        self.phaseDeadline = phaseDeadline
        self.lifecycle = lifecycle
        self.drains = drains
        self.drainGroup = drainGroup
    }

    /// Infallibly transfers both stream descriptors into two memory drains,
    /// starts both workers, and starts exact-PID death observation. A failed
    /// second descriptor transfer cannot be represented. The fixed caller
    /// validates its chunk configuration before spawning.
    static func adoptMemory(
        spawn: PrimeSecureChildSpawnHandle,
        phaseDeadline:
            PrimeSecureChildPhaseDeadline,
        standardOutputMaximumByteCount:
            UInt64,
        standardErrorMaximumByteCount:
            UInt64,
        chunkByteCount: Int
    ) -> PrimeSecureChildSupervisionCapability {
        let descriptors =
            spawn.takeStreamReadDescriptors()
        let group = DispatchGroup()
        let standardOutput =
            PrimeSecureChildMemoryBoundedDrain(
                descriptor:
                    descriptors.standardOutput,
                maximumByteCount:
                    standardOutputMaximumByteCount,
                chunkByteCount:
                    chunkByteCount
            )
        let standardError =
            PrimeSecureChildMemoryBoundedDrain(
                descriptor:
                    descriptors.standardError,
                maximumByteCount:
                    standardErrorMaximumByteCount,
                chunkByteCount:
                    chunkByteCount
            )
        standardOutput.start(group: group)
        standardError.start(group: group)
        let lifecycle =
            PrimeSecureChildLifecycle.liveDarwin(
                processIdentifier:
                    spawn.processIdentifier
            )
        lifecycle.startDeathObservation()
        return PrimeSecureChildSupervisionCapability(
            spawn: spawn,
            phaseDeadline: phaseDeadline,
            lifecycle: lifecycle,
            drains:
                .memory(
                    standardOutput:
                        standardOutput,
                    standardError:
                        standardError
                ),
            drainGroup: group
        )
    }

    /// Infallibly transfers both stream descriptors into two file-backed
    /// drains. The output descriptors are consumed with them and are finalized
    /// only by the corresponding drain workers.
    static func adoptFileBacked(
        spawn: PrimeSecureChildSpawnHandle,
        phaseDeadline:
            PrimeSecureChildPhaseDeadline,
        standardOutputDescriptor: Int32,
        standardErrorDescriptor: Int32,
        maximumByteCount: UInt64
    ) -> PrimeSecureChildSupervisionCapability {
        let descriptors =
            spawn.takeStreamReadDescriptors()
        let group = DispatchGroup()
        let standardOutput =
            PrimeSecureChildFileBackedBoundedDrain(
                inputDescriptor:
                    descriptors.standardOutput,
                outputDescriptor:
                    standardOutputDescriptor,
                maximumByteCount:
                    maximumByteCount
            )
        let standardError =
            PrimeSecureChildFileBackedBoundedDrain(
                inputDescriptor:
                    descriptors.standardError,
                outputDescriptor:
                    standardErrorDescriptor,
                maximumByteCount:
                    maximumByteCount
            )
        standardOutput.start(group: group)
        standardError.start(group: group)
        let lifecycle =
            PrimeSecureChildLifecycle.liveDarwin(
                processIdentifier:
                    spawn.processIdentifier
            )
        lifecycle.startDeathObservation()
        return PrimeSecureChildSupervisionCapability(
            spawn: spawn,
            phaseDeadline: phaseDeadline,
            lifecycle: lifecycle,
            drains:
                .fileBacked(
                    standardOutput:
                        standardOutput,
                    standardError:
                        standardError
                ),
            drainGroup: group
        )
    }

    var processIdentifier: Int32 {
        spawn.processIdentifier
    }

    var appliedFlags: UInt16 {
        spawn.appliedFlags
    }

    var spawnReturnCode: Int32 {
        spawn.spawnReturnCode
    }

    var spawnReturnedMonotonicNanoseconds:
        UInt64
    {
        spawn.spawnReturnedMonotonicNanoseconds
    }

    var exactPIDWaitObservation:
        PrimeSecureChildExactPIDWaitObservation?
    {
        lifecycle.exactPIDWaitObservation
    }

    /// A read-only record of the cleanup timing plan, if cleanup reached
    /// timeline construction. Signal delivery outcomes remain lifecycle-owned
    /// and unavailable through this seam.
    var cleanupTimelineSnapshot:
        PrimeSecureChildCleanupTimeline?
    {
        retainedCleanupTimeline
    }

    /// Joins the suspended child to the session and process-group authority
    /// before that authority is recorded in the lifecycle.
    func establishIsolatedSessionAndDedicatedGroup()
        -> Bool
    {
        guard activeOperationsAreAuthorized,
              case .suspended = executionState,
              getsid(processIdentifier)
                == processIdentifier,
              getpgid(processIdentifier)
                == processIdentifier
        else {
            return false
        }
        spawn
            .recordIsolatedSessionAndDedicatedGroupAuthority()
        return lifecycle
            .establishIsolatedSessionAndDedicatedGroup()
    }

    /// SIGCONT is authorized only by the retained phase deadline and the last
    /// caller-observed pre-resume checkpoint. Deadline arithmetic failures are
    /// thrown rather than collapsed into ordinary expiry.
    func resume(
        notBeforeUptimeNanoseconds:
            UInt64
    ) throws -> PrimeSecureChildResumeDisposition {
        guard activeOperationsAreAuthorized,
              case .suspended = executionState
        else {
            return .stateRejected
        }
        let beforeSignal =
            DispatchTime.now()
            .uptimeNanoseconds
        guard try phaseDeadline
            .authorizesNewWork(
                observedAtUptimeNanoseconds:
                    beforeSignal,
                notBeforeUptimeNanoseconds:
                    notBeforeUptimeNanoseconds
            )
        else {
            return .deadlineExpired
        }
        errno = 0
        guard Darwin.kill(
            processIdentifier,
            SIGCONT
        ) == 0 else {
            return .signalFailed(errno)
        }
        guard lifecycle.markResumed() else {
            executionState = .cleanupRequired(
                .invalidLifecycleTransition
            )
            return .stateRejected
        }
        executionState = .resumed
        let deliveredAt =
            DispatchTime.now()
            .uptimeNanoseconds
        guard deliveredAt
                > notBeforeUptimeNanoseconds
        else {
            return .stateRejected
        }
        guard try phaseDeadline
            .authorizesNewWork(
                observedAtUptimeNanoseconds:
                    deliveredAt,
                notBeforeUptimeNanoseconds:
                    beforeSignal
            )
        else {
            return .deadlineExpired
        }
        return .resumed(
            deliveredAtUptimeNanoseconds:
                deliveredAt
        )
    }

    func observeDeath() throws
        -> PrimeSecureChildDeathObservationDisposition
    {
        guard activeOperationsAreAuthorized,
              case .resumed = executionState
        else {
            return .stateRejected
        }
        return try lifecycle.observeDeath(
            until: phaseDeadline
        ) ? .observed : .deadlineExpired
    }

    func deathObservedMonotonicNanoseconds()
        -> UInt64?
    {
        lifecycle
            .deathObservedMonotonicNanoseconds()
    }

    func processGroupMemberIdentifiers()
        -> [Int32]?
    {
        guard activeOperationsAreAuthorized
        else {
            return nil
        }
        switch executionState {
        case .suspended, .resumed:
            return lifecycle
                .processGroupMemberIdentifiers()
        case .reaped, .cleanupRequired:
            return nil
        }
    }

    func reapAfterObservedDeath()
        -> PrimeSecureChildReapDisposition
    {
        guard activeOperationsAreAuthorized,
              case .resumed = executionState
        else {
            executionState = .cleanupRequired(
                .invalidLifecycleTransition
            )
            return .mustFailStop(
                .invalidLifecycleTransition
            )
        }
        let disposition =
            lifecycle.reapAfterObservedDeath()
        switch disposition {
        case .reaped:
            guard lifecycle
                    .exactPIDWaitObservation
                    != nil
            else {
                executionState =
                    .cleanupRequired(
                        .exactPIDWaitFailed
                    )
                return .mustFailStop(
                    .exactPIDWaitFailed
                )
            }
            executionState = .reaped
            spawn
                .dischargeChildObligationAfterExactReap()
        case let .mustFailStop(reason):
            executionState =
                .cleanupRequired(reason)
        }
        return disposition
    }

    func waitForPhaseDrainCompletion(
        notBeforeUptimeNanoseconds:
            UInt64
    ) throws -> PrimeSecureChildPhaseDrainDisposition {
        guard activeOperationsAreAuthorized,
              case .resumed = executionState
        else {
            return .stateRejected
        }
        let waitStartedAt =
            DispatchTime.now()
            .uptimeNanoseconds
        guard try phaseDeadline
            .acceptsCompletion(
                observedAtUptimeNanoseconds:
                    waitStartedAt,
                notBeforeUptimeNanoseconds:
                    notBeforeUptimeNanoseconds
            )
        else {
            return .deadlineExpired
        }
        guard drainGroup.wait(
            timeout: phaseDeadline.dispatchTime
        ) == .success
        else {
            return .deadlineExpired
        }
        let completedAt =
            DispatchTime.now()
            .uptimeNanoseconds
        guard try phaseDeadline
            .acceptsCompletion(
                observedAtUptimeNanoseconds:
                    completedAt,
                notBeforeUptimeNanoseconds:
                    waitStartedAt
            )
        else {
            return .deadlineExpired
        }
        return .completed(
            drainEvidence()
        )
    }

    func drainEvidence()
        -> PrimeSecureChildDrainEvidence
    {
        switch drains {
        case let .memory(
            standardOutput,
            standardError
        ):
            return .memory(
                standardOutput:
                    standardOutput.snapshot(),
                standardError:
                    standardError.snapshot()
            )
        case let .fileBacked(
            standardOutput,
            standardError
        ):
            return .fileBacked(
                standardOutput:
                    standardOutput.snapshot(),
                standardError:
                    standardError.snapshot()
            )
        }
    }

    /// Contains the exact child and both drains under one cleanup-only
    /// timeline. A prior mandatory failure is latched and can never be
    /// downgraded by a later exact reap or finished drain.
    func cleanupRejectedCapture()
        -> PrimeSecureChildCleanupDisposition
    {
        switch cleanupState {
        case let .completed(disposition):
            return disposition
        case .running:
            return .mustFailStop(
                .invalidLifecycleTransition
            )
        case .notStarted:
            break
        }

        var authority =
            latchedFailureAuthority()
        if lifecycle.exactPIDWaitObservation
                != nil
        {
            spawn
                .dischargeChildObligationAfterExactReap()
        }
        if lifecycle.exactPIDWaitObservation
                != nil,
           drainsAreTerminalAndClosed()
        {
            let disposition =
                disposition(
                    preserving: authority,
                    otherwise: .contained
                )
            completeCleanup(
                with: disposition
            )
            return disposition
        }

        let timeline:
            PrimeSecureChildCleanupTimeline
        do {
            timeline = try lifecycle
                .cleanupTimeline()
        } catch {
            lifecycle.attemptEmergencySIGKILL()
            let disposition:
                PrimeSecureChildCleanupDisposition =
                .mustFailStop(
                    .invalidLifecycleTransition
                )
            completeCleanup(
                with: disposition
            )
            return disposition
        }
        retainedCleanupTimeline = timeline
        cleanupState = .running(timeline)

        if !lifecycle.hasReaped {
            switch lifecycle
                .cleanupRejectedCapture(
                    using: timeline
                )
            {
            case .contained:
                break
            case let .mustFailStop(reason):
                authority = authority
                    .preservingFirst(reason)
            }
        }
        if lifecycle.exactPIDWaitObservation
                != nil
        {
            spawn
                .dischargeChildObligationAfterExactReap()
        }
        if lifecycle.hasReaped,
           lifecycle.exactPIDWaitObservation == nil
        {
            authority = authority
                .preservingFirst(
                    .exactPIDWaitFailed
                )
        }

        let drainDisposition =
            cleanupDrains(using: timeline)
        let finalDisposition =
            disposition(
                preserving: authority,
                otherwise:
                    drainDisposition
            )
        completeCleanup(
            with: finalDisposition
        )
        return finalDisposition
    }

    /// This checks only drain ownership. Callers may accept a closed terminal
    /// error as contained only after the exact child has independently been
    /// reaped; ordinary fixture success still validates clean EOF separately.
    static func memoryDrainContainmentDisposition(
        standardOutput:
            PrimeSecureChildMemoryDrainSnapshot,
        standardError:
            PrimeSecureChildMemoryDrainSnapshot
    ) -> PrimeSecureChildCleanupDisposition {
        standardOutput.workerFinished
            && standardOutput.descriptorsClosed
            && standardOutput.terminalReason
                != .active
            && standardError.workerFinished
            && standardError.descriptorsClosed
            && standardError.terminalReason
                != .active
            ? .contained
            : .mustFailStop(
                .streamDrainUncontained
            )
    }

    private static func fileBackedDrainContainmentDisposition(
        standardOutput:
            PrimeSecureChildFileBackedDrainSnapshot,
        standardError:
            PrimeSecureChildFileBackedDrainSnapshot
    ) -> PrimeSecureChildCleanupDisposition {
        standardOutput.workerFinished
            && standardOutput.descriptorsClosed
            && standardOutput.terminalReason
                != .active
            && standardError.workerFinished
            && standardError.descriptorsClosed
            && standardError.terminalReason
                != .active
            ? .contained
            : .mustFailStop(
                .streamDrainUncontained
            )
    }

    private func cleanupDrains(
        using timeline:
            PrimeSecureChildCleanupTimeline
    ) -> PrimeSecureChildCleanupDisposition {
        switch drains {
        case let .memory(
            standardOutput,
            standardError
        ):
            if drainGroup.wait(
                timeout:
                    timeline
                    .containmentDeadline
                    .dispatchTime
            ) != .success {
                standardOutput.requestStop()
                standardError.requestStop()
            }
            guard drainGroup.wait(
                timeout:
                    timeline
                    .drainDeadline
                    .dispatchTime
            ) == .success
            else {
                return .mustFailStop(
                    .streamDrainUncontained
                )
            }
            return Self
                .memoryDrainContainmentDisposition(
                    standardOutput:
                        standardOutput.snapshot(),
                    standardError:
                        standardError.snapshot()
                )
        case let .fileBacked(
            standardOutput,
            standardError
        ):
            if drainGroup.wait(
                timeout:
                    timeline
                    .containmentDeadline
                    .dispatchTime
            ) != .success {
                standardOutput.requestStop()
                standardError.requestStop()
            }
            guard drainGroup.wait(
                timeout:
                    timeline
                    .drainDeadline
                    .dispatchTime
            ) == .success
            else {
                return .mustFailStop(
                    .streamDrainUncontained
                )
            }
            return Self
                .fileBackedDrainContainmentDisposition(
                    standardOutput:
                        standardOutput.snapshot(),
                    standardError:
                        standardError.snapshot()
                )
        }
    }

    private func drainsAreTerminalAndClosed()
        -> Bool
    {
        switch drainEvidence() {
        case let .memory(
            standardOutput,
            standardError
        ):
            return Self
                .memoryDrainContainmentDisposition(
                    standardOutput:
                        standardOutput,
                    standardError:
                        standardError
                ) == .contained
        case let .fileBacked(
            standardOutput,
            standardError
        ):
            return Self
                .fileBackedDrainContainmentDisposition(
                    standardOutput:
                        standardOutput,
                    standardError:
                        standardError
                ) == .contained
        }
    }

    private func latchedFailureAuthority()
        -> FailureAuthority
    {
        if case let .cleanupRequired(reason) =
            executionState
        {
            return .mustFailStop(reason)
        }
        return .none
    }

    private var activeOperationsAreAuthorized:
        Bool
    {
        if case .notStarted = cleanupState {
            return true
        }
        return false
    }

    private func completeCleanup(
        with disposition:
            PrimeSecureChildCleanupDisposition
    ) {
        cleanupState = .completed(disposition)
        switch disposition {
        case .contained:
            executionState = .reaped
        case let .mustFailStop(reason):
            executionState =
                .cleanupRequired(reason)
        }
    }

    private func disposition(
        preserving authority: FailureAuthority,
        otherwise fallback:
            PrimeSecureChildCleanupDisposition
    ) -> PrimeSecureChildCleanupDisposition {
        switch authority {
        case .none:
            return fallback
        case let .mustFailStop(reason):
            return .mustFailStop(reason)
        }
    }

    deinit {
        let terminalReturnIsAuthorized:
            Bool
        switch cleanupState {
        case .completed(.contained):
            terminalReturnIsAuthorized = true
        case .notStarted:
            if case .reaped = executionState {
                terminalReturnIsAuthorized = true
            } else {
                terminalReturnIsAuthorized = false
            }
        case .running,
             .completed(.mustFailStop):
            terminalReturnIsAuthorized = false
        }
        guard terminalReturnIsAuthorized,
              lifecycle.exactPIDWaitObservation
                != nil,
              drainsAreTerminalAndClosed()
        else {
            lifecycle.attemptEmergencySIGKILL()
            Darwin._exit(70)
        }
    }
}
