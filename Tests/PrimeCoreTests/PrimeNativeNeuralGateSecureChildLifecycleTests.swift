import Darwin
import Dispatch
import Foundation
import XCTest
@testable import PrimeCore

final class PrimeNativeNeuralGateSecureChildLifecycleTests:
    XCTestCase
{
    private typealias Capture =
        PrimeNativeNeuralGateSecureExternalChildCapture
    private typealias Lifecycle =
        PrimeSecureChildLifecycle

    func testPreJoinRejectionUsesPositivePIDSIGKILLOnly() {
        let processIdentifier: Int32 = 4_101
        let harness = Harness(
            processIdentifier: processIdentifier
        )
        harness.deathNotifications = [
            101,
        ]
        harness.waitResults = [
            .reaped(
                returnedPID: processIdentifier,
                rawStatus: SIGKILL
            ),
        ]
        let child = harness.makeLifecycle()
        child.startDeathObservation()

        XCTAssertEqual(
            cleanup(child),
            .contained
        )
        XCTAssertEqual(
            child.authority,
            .directPIDOnly
        )
        XCTAssertEqual(
            harness.signals,
            [
                .init(
                    target:
                        .directPID(
                            processIdentifier
                        ),
                    signal: .kill
                ),
            ]
        )
        XCTAssertGreaterThan(
            processIdentifier,
            0
        )
        XCTAssertEqual(
            harness.waitModes,
            [
                .blockingAfterObservedDeath,
            ]
        )
        XCTAssertEqual(
            harness.returnedPIDReapCount,
            1
        )
        XCTAssertEqual(
            harness.processGroupMembersCallCount,
            0
        )
        XCTAssertEqual(
            harness.processGroupEmptyCallCount,
            0
        )
        XCTAssertTrue(child.hasReaped)
    }

    func testProvenSessionPreResumeRejectionUsesGroupSIGKILLOnce() {
        let processIdentifier: Int32 = 4_102
        let harness = Harness(
            processIdentifier: processIdentifier
        )
        harness.deathNotifications = [
            102,
        ]
        harness.waitResults = [
            .reaped(
                returnedPID: processIdentifier,
                rawStatus: SIGKILL
            ),
        ]
        let child = harness.makeLifecycle()
        child.startDeathObservation()
        XCTAssertTrue(
            child
                .establishIsolatedSessionAndDedicatedGroup()
        )

        let phase = try! PrimeSecureChildPhaseDeadline(
            startUptimeNanoseconds: 100,
            durationNanoseconds: 10
        )
        XCTAssertTrue(
            try! phase.authorizesNewWork(
                observedAtUptimeNanoseconds: 109
            )
        )
        XCTAssertFalse(
            try! phase.authorizesNewWork(
                observedAtUptimeNanoseconds: 110
            )
        )
        XCTAssertThrowsError(
            try phase.authorizesNewWork(
                observedAtUptimeNanoseconds: 99
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeSecureChildDeadlineError,
                .clockRegression(
                    observedUptimeNanoseconds: 99,
                    notBeforeUptimeNanoseconds: 100
                )
            )
        }
        let cleanupTimeline =
            try! PrimeSecureChildCleanupTimeline
            .suspended(
                cleanupStartedAtUptimeNanoseconds:
                    1_000
            )
        guard case let .suspended(killDeadline) =
                cleanupTimeline.signalPlan
        else {
            return XCTFail(
                "pre-resume cleanup gained a TERM stage"
            )
        }
        XCTAssertEqual(
            killDeadline
                .expiresAtUptimeNanoseconds,
            1_000 + 2_000_000_000
        )
        XCTAssertEqual(
            cleanupTimeline
                .containmentDeadline
                .expiresAtUptimeNanoseconds,
            1_000 + 4_000_000_000
        )
        XCTAssertEqual(
            cleanupTimeline
                .drainDeadline
                .expiresAtUptimeNanoseconds,
            1_000 + 7_000_000_000
        )
        XCTAssertFalse(child.resumed)

        XCTAssertEqual(
            cleanup(child),
            .contained
        )
        XCTAssertFalse(child.resumed)
        XCTAssertEqual(
            harness.signals,
            [
                .init(
                    target:
                        .processGroup(
                            processIdentifier
                        ),
                    signal: .kill
                ),
            ]
        )
        XCTAssertFalse(
            harness.signals.contains {
                $0.signal == .terminate
            }
        )
        XCTAssertEqual(
            harness.processGroupMemberObservations,
            [
                [
                    processIdentifier,
                ],
            ]
        )
        XCTAssertEqual(
            harness.waitModes,
            [
                .blockingAfterObservedDeath,
            ]
        )
        XCTAssertEqual(
            harness.processGroupEmptyCallCount,
            1
        )
        XCTAssertEqual(
            harness.returnedPIDReapCount,
            1
        )
    }

    func testResumedDeadlineEscalatesGroupSIGTERMThenSIGKILL() {
        let processIdentifier: Int32 = 4_103
        let harness = Harness(
            processIdentifier: processIdentifier
        )
        harness.nowValue = 50
        let timeline =
            try! PrimeSecureChildCleanupTimeline
            .resumed(
                cleanupStartedAtUptimeNanoseconds:
                    harness.nowValue
            )
        guard case let .resumed(
            terminationDeadline,
            killDeadline
        ) = timeline.signalPlan else {
            return XCTFail(
                "resumed cleanup lost its TERM stage"
            )
        }
        harness.deathNotifications = [
            terminationDeadline
                .expiresAtUptimeNanoseconds + 1,
            killDeadline
                .expiresAtUptimeNanoseconds,
        ]
        harness.waitResults = [
            .reaped(
                returnedPID: processIdentifier,
                rawStatus: SIGKILL
            ),
        ]
        let child = harness.makeLifecycle()
        child.startDeathObservation()
        XCTAssertTrue(
            child
                .establishIsolatedSessionAndDedicatedGroup()
        )
        XCTAssertTrue(child.markResumed())

        XCTAssertEqual(
            child.cleanupRejectedCapture(
                using: timeline
            ),
            .contained
        )
        XCTAssertEqual(
            harness.signals,
            [
                .init(
                    target:
                        .processGroup(
                            processIdentifier
                        ),
                    signal: .terminate
                ),
                .init(
                    target:
                        .processGroup(
                            processIdentifier
                        ),
                    signal: .kill
                ),
            ]
        )
        XCTAssertEqual(
            harness.signals.filter {
                $0.signal == .kill
            }.count,
            1
        )
        XCTAssertEqual(
            harness.awaitedDeathDeadlines,
            [
                terminationDeadline
                    .expiresAtUptimeNanoseconds,
                killDeadline
                    .expiresAtUptimeNanoseconds,
            ]
        )
        XCTAssertEqual(
            timeline
                .containmentDeadline
                .expiresAtUptimeNanoseconds,
            50 + 6_000_000_000
        )
        XCTAssertEqual(
            timeline
                .drainDeadline
                .expiresAtUptimeNanoseconds,
            50 + 9_000_000_000
        )
        XCTAssertFalse(
            harness.awaitedDeathDeadlines
                .contains(UInt64.max)
        )
        XCTAssertEqual(
            harness.operationLog,
            [
                "start_death_observation",
                "signal_terminate",
                "await_death",
                "signal_kill",
                "await_death",
                "process_group_members",
                "wait_exact_pid",
                "cancel_death_observation",
                "process_group_empty",
            ]
        )
        XCTAssertThrowsError(
            try PrimeSecureChildPhaseDeadline(
                startUptimeNanoseconds: 0,
                durationNanoseconds: 0
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeSecureChildDeadlineError,
                .zeroDuration
            )
        }
        XCTAssertThrowsError(
            try PrimeSecureChildPhaseDeadline(
                startUptimeNanoseconds: 0,
                durationSeconds: UInt64.max
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeSecureChildDeadlineError,
                .durationOverflow
            )
        }
        XCTAssertThrowsError(
            try PrimeSecureChildPhaseDeadline(
                startUptimeNanoseconds:
                    UInt64.max - 5,
                durationNanoseconds: 6
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeSecureChildDeadlineError,
                .endpointOverflow
            )
        }
        XCTAssertThrowsError(
            try PrimeSecureChildPhaseDeadline(
                startUptimeNanoseconds:
                    UInt64.max - 5,
                durationNanoseconds: 5
            )
        ) {
            XCTAssertEqual(
                $0 as? PrimeSecureChildDeadlineError,
                .reservedEndpoint
            )
        }
        XCTAssertEqual(
            harness.waitModes,
            [
                .blockingAfterObservedDeath,
            ]
        )
        XCTAssertEqual(
            harness.returnedPIDReapCount,
            1
        )
    }

    func testObservedDeathAfterSIGTERMSuppressesSIGKILL() {
        let processIdentifier: Int32 = 4_104
        let harness = Harness(
            processIdentifier: processIdentifier
        )
        harness.nowValue = 100
        let phase = try! PrimeSecureChildPhaseDeadline(
            startUptimeNanoseconds: 100,
            durationNanoseconds: 10
        )
        XCTAssertTrue(
            try! phase.acceptsCompletion(
                observedAtUptimeNanoseconds: 110
            )
        )
        XCTAssertFalse(
            try! phase.acceptsCompletion(
                observedAtUptimeNanoseconds: 111
            )
        )
        let timeline =
            try! PrimeSecureChildCleanupTimeline
            .resumed(
                cleanupStartedAtUptimeNanoseconds:
                    harness.nowValue
            )
        guard case let .resumed(
            terminationDeadline,
            _
        ) = timeline.signalPlan else {
            return XCTFail(
                "resumed cleanup lost its TERM stage"
            )
        }
        harness.deathNotifications = [
            terminationDeadline
                .expiresAtUptimeNanoseconds,
        ]
        harness.waitResults = [
            .reaped(
                returnedPID: processIdentifier,
                rawStatus: SIGTERM
            ),
        ]
        let child = harness.makeLifecycle()
        child.startDeathObservation()
        XCTAssertTrue(
            child
                .establishIsolatedSessionAndDedicatedGroup()
        )
        XCTAssertTrue(child.markResumed())

        XCTAssertEqual(
            child.cleanupRejectedCapture(
                using: timeline
            ),
            .contained
        )
        XCTAssertEqual(
            harness.signals,
            [
                .init(
                    target:
                        .processGroup(
                            processIdentifier
                        ),
                    signal: .terminate
                ),
            ]
        )
        XCTAssertFalse(
            harness.signals.contains {
                $0.signal == .kill
            }
        )
        XCTAssertEqual(
            harness.waitModes,
            [
                .blockingAfterObservedDeath,
            ]
        )
        XCTAssertEqual(
            child.exactPIDWaitObservation?
                .returnedProcessIdentifier,
            processIdentifier
        )
        XCTAssertEqual(
            child.exactPIDWaitObservation?
                .terminationSignal,
            SIGTERM
        )
    }

    func testMissingDeathAfterSIGKILLUsesBoundedWNOHANGThenFailStops() {
        let processIdentifier: Int32 = 4_105
        let harness = Harness(
            processIdentifier: processIdentifier
        )
        harness.nowValue = 75
        harness.deathNotifications = [
            nil,
            nil,
        ]
        let child = harness.makeLifecycle()
        child.startDeathObservation()
        XCTAssertTrue(
            child
                .establishIsolatedSessionAndDedicatedGroup()
        )
        XCTAssertTrue(child.markResumed())

        XCTAssertEqual(
            cleanup(child),
            .mustFailStop(
                .childUncontainedAfterSIGKILL
            )
        )
        XCTAssertEqual(
            harness.signals,
            [
                .init(
                    target:
                        .processGroup(
                            processIdentifier
                        ),
                    signal: .terminate
                ),
                .init(
                    target:
                        .processGroup(
                            processIdentifier
                        ),
                    signal: .kill
                ),
            ]
        )
        XCTAssertEqual(
            harness.awaitedDeathDeadlines,
            [
                75
                    + PrimeSecureChildCleanupTimeline
                    .signalGraceNanoseconds,
                75
                    + 2
                    * PrimeSecureChildCleanupTimeline
                    .signalGraceNanoseconds,
            ]
        )
        XCTAssertEqual(
            harness.waitModes.count,
            Lifecycle.maximumContainmentPollCount
        )
        XCTAssertTrue(
            harness.waitModes.allSatisfy {
                $0
                    == .nonblockingContainmentProbe
            }
        )
        XCTAssertEqual(
            harness.advanceContainmentPollCount,
            Lifecycle.maximumContainmentPollCount
        )
        XCTAssertEqual(
            harness.returnedPIDReapCount,
            0
        )
        XCTAssertFalse(child.hasReaped)
    }

    func testWNOHANGFallbackReapsExactChildOnce() {
        let processIdentifier: Int32 = 4_106
        let rawStatus: Int32 = SIGKILL
        let harness = Harness(
            processIdentifier: processIdentifier
        )
        harness.deathNotifications = [
            nil,
        ]
        harness.waitResults = [
            .stillRunning,
            .reaped(
                returnedPID: processIdentifier,
                rawStatus: rawStatus
            ),
        ]
        let child = harness.makeLifecycle()
        child.startDeathObservation()

        XCTAssertEqual(
            cleanup(child),
            .contained
        )
        XCTAssertEqual(
            harness.signals,
            [
                .init(
                    target:
                        .directPID(
                            processIdentifier
                        ),
                    signal: .kill
                ),
            ]
        )
        XCTAssertEqual(
            harness.waitModes,
            [
                .nonblockingContainmentProbe,
                .nonblockingContainmentProbe,
            ]
        )
        XCTAssertFalse(
            harness.waitModes.contains(
                .blockingAfterObservedDeath
            )
        )
        XCTAssertEqual(
            harness.returnedPIDReapCount,
            1
        )
        XCTAssertEqual(
            harness.advanceContainmentPollCount,
            1
        )
        XCTAssertEqual(
            harness.cancelDeathObservationCallCount,
            1
        )
        XCTAssertTrue(child.hasReaped)
    }

    func testOverflowDrainsThroughEOFThenRejectsWithoutExtraSignalOrReap()
        throws
    {
        let maximumByteCount: UInt64 = 8
        let payload = Data(
            repeating: 0x61,
            count: 64
        )
        let snapshot =
            try drainPipeToEOF(
                payload: payload,
                maximumByteCount:
                    maximumByteCount
            )

        XCTAssertEqual(
            snapshot.data.count,
            Int(maximumByteCount)
        )
        XCTAssertEqual(
            snapshot.totalByteCount,
            UInt64(payload.count)
        )
        XCTAssertTrue(snapshot.overflowed)
        XCTAssertTrue(snapshot.reachedEOF)
        XCTAssertTrue(snapshot.workerFinished)
        XCTAssertEqual(
            snapshot.terminalReason,
            .endOfFile
        )
        XCTAssertTrue(
            snapshot.descriptorsClosed
        )
        XCTAssertEqual(
            snapshot.readErrorNumber,
            0
        )
        XCTAssertEqual(
            snapshot.writeErrorNumber,
            0
        )
        XCTAssertEqual(
            snapshot.finalizationErrorNumber,
            0
        )
        XCTAssertEqual(
            snapshot.closeErrorNumber,
            0
        )

        let processIdentifier: Int32 = 4_107
        let harness = Harness(
            processIdentifier: processIdentifier
        )
        let child =
            makeAlreadyReapedLifecycle(
                harness: harness
            )
        let signalCount = harness.signals.count
        let waitCount = harness.waitModes.count

        XCTAssertEqual(
            PrimeSecureChildSupervisionCapability
                .memoryDrainContainmentDisposition(
                    standardOutput: snapshot,
                    standardError:
                        finishedEOFSnapshot()
            ),
            .contained
        )
        XCTAssertEqual(
            cleanup(child),
            .contained
        )
        XCTAssertEqual(
            harness.signals.count,
            signalCount
        )
        XCTAssertEqual(
            harness.waitModes.count,
            waitCount
        )
        XCTAssertEqual(waitCount, 1)
        XCTAssertEqual(
            harness.returnedPIDReapCount,
            1
        )
    }

    func testReadFailureWithTerminatedDrainWorkerRejectsButDoesNotClaimEOF()
        throws
    {
        let snapshot =
            try drainClosedReadDescriptor()

        XCTAssertTrue(snapshot.workerFinished)
        XCTAssertEqual(
            snapshot.terminalReason,
            .readError
        )
        XCTAssertFalse(snapshot.reachedEOF)
        XCTAssertFalse(snapshot.overflowed)
        XCTAssertNotEqual(
            snapshot.readErrorNumber,
            0
        )
        XCTAssertEqual(
            snapshot.readErrorNumber,
            EBADF
        )
        XCTAssertEqual(
            snapshot.finalizationErrorNumber,
            0
        )
        XCTAssertEqual(
            snapshot.closeErrorNumber,
            EBADF
        )
        XCTAssertFalse(
            snapshot.descriptorsClosed
        )
        XCTAssertFalse(
            snapshot.workerFinished
                && snapshot.reachedEOF
                && snapshot.readErrorNumber
                    == 0
                && !snapshot.overflowed
        )

        let closedReadFailure =
            Capture.DrainSnapshot(
                terminalReason: .readError,
                data: Data(),
                totalByteCount: 0,
                overflowed: false,
                workerFinished: true,
                reachedEOF: false,
                readErrorNumber: EIO,
                writeErrorNumber: 0,
                finalizationErrorNumber: 0,
                closeErrorNumber: 0,
                descriptorsClosed: true
            )

        let processIdentifier: Int32 = 4_108
        let harness = Harness(
            processIdentifier: processIdentifier
        )
        let child =
            makeAlreadyReapedLifecycle(
                harness: harness
            )
        let signalCount = harness.signals.count
        let waitCount = harness.waitModes.count

        XCTAssertEqual(
            PrimeSecureChildSupervisionCapability
                .memoryDrainContainmentDisposition(
                    standardOutput: snapshot,
                    standardError:
                        finishedEOFSnapshot()
            ),
            .mustFailStop(
                .streamDrainUncontained
            )
        )
        XCTAssertEqual(
            PrimeSecureChildSupervisionCapability
                .memoryDrainContainmentDisposition(
                    standardOutput:
                        closedReadFailure,
                    standardError:
                        finishedEOFSnapshot()
                ),
            .contained
        )
        XCTAssertEqual(
            cleanup(child),
            .contained
        )
        XCTAssertEqual(
            harness.signals.count,
            signalCount
        )
        XCTAssertEqual(
            harness.waitModes.count,
            waitCount
        )
    }

    func testUncontainedDrainWorkerProducesFailStopDisposition() {
        let active =
            Capture.DrainSnapshot(
                terminalReason: .active,
                data: Data(),
                totalByteCount: 0,
                overflowed: false,
                workerFinished: false,
                reachedEOF: false,
                readErrorNumber: 0,
                writeErrorNumber: 0,
                finalizationErrorNumber: 0,
                closeErrorNumber: 0,
                descriptorsClosed: false
            )
        let closedWriteFinalizationFailure =
            Capture.DrainSnapshot(
                terminalReason:
                    .writeOrFinalizationError,
                data: Data(),
                totalByteCount: 0,
                overflowed: false,
                workerFinished: true,
                reachedEOF: false,
                readErrorNumber: 0,
                writeErrorNumber: EIO,
                finalizationErrorNumber: EIO,
                closeErrorNumber: 0,
                descriptorsClosed: true
            )
        let closedCleanupStop =
            Capture.DrainSnapshot(
                terminalReason: .cleanupStop,
                data: Data(),
                totalByteCount: 0,
                overflowed: false,
                workerFinished: true,
                reachedEOF: false,
                readErrorNumber: 0,
                writeErrorNumber: 0,
                finalizationErrorNumber: 0,
                closeErrorNumber: 0,
                descriptorsClosed: true
            )

        XCTAssertEqual(
            PrimeSecureChildSupervisionCapability
                .memoryDrainContainmentDisposition(
                    standardOutput: active,
                    standardError:
                        finishedEOFSnapshot()
            ),
            .mustFailStop(
                .streamDrainUncontained
            )
        )
        XCTAssertEqual(
            PrimeSecureChildSupervisionCapability
                .memoryDrainContainmentDisposition(
                    standardOutput:
                        closedWriteFinalizationFailure,
                    standardError:
                        closedCleanupStop
                ),
            .contained
        )
        XCTAssertEqual(
            PrimeSecureChildSupervisionCapability
                .memoryDrainContainmentDisposition(
                    standardOutput:
                        finishedEOFSnapshot(),
                    standardError: active
                ),
            .mustFailStop(
                .streamDrainUncontained
            )
        )

        let processIdentifier: Int32 = 4_109
        let harness = Harness(
            processIdentifier: processIdentifier
        )
        let child =
            makeAlreadyReapedLifecycle(
                harness: harness
            )
        let signalCount = harness.signals.count
        let waitCount = harness.waitModes.count

        XCTAssertEqual(
            cleanup(child),
            .contained
        )
        XCTAssertEqual(
            harness.signals.count,
            signalCount
        )
        XCTAssertEqual(
            harness.waitModes.count,
            waitCount
        )
    }

    func testReapedStateForbidsSignalsAndSecondReap() {
        let processIdentifier: Int32 = 4_110
        let harness = Harness(
            processIdentifier: processIdentifier
        )
        let child =
            makeAlreadyReapedLifecycle(
                harness: harness,
                establishGroupAuthority: true
            )
        let signalCount = harness.signals.count
        let waitCount = harness.waitModes.count
        let startCount =
            harness
            .startDeathObservationCallCount

        XCTAssertEqual(
            cleanup(child),
            .contained
        )
        XCTAssertEqual(
            child.reapAfterObservedDeath(),
            .mustFailStop(
                .invalidLifecycleTransition
            )
        )
        XCTAssertFalse(
            child
                .establishIsolatedSessionAndDedicatedGroup()
        )
        XCTAssertFalse(child.markResumed())
        XCTAssertNil(
            child
                .processGroupMemberIdentifiers()
        )
        child.startDeathObservation()

        XCTAssertEqual(
            harness.signals.count,
            signalCount
        )
        XCTAssertEqual(
            harness.waitModes.count,
            waitCount
        )
        XCTAssertEqual(waitCount, 1)
        XCTAssertEqual(
            harness.returnedPIDReapCount,
            1
        )
        XCTAssertEqual(
            harness
                .startDeathObservationCallCount,
            startCount
        )
    }

    private func cleanup(
        _ child: Lifecycle,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> PrimeSecureChildCleanupDisposition {
        do {
            return child.cleanupRejectedCapture(
                using: try child.cleanupTimeline()
            )
        } catch {
            XCTFail(
                "cleanup timeline construction failed: \(error)",
                file: file,
                line: line
            )
            return .mustFailStop(
                .invalidLifecycleTransition
            )
        }
    }

    private func makeAlreadyReapedLifecycle(
        harness: Harness,
        establishGroupAuthority: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Lifecycle {
        harness.deathNotifications = [
            1_000,
        ]
        harness.waitResults = [
            .reaped(
                returnedPID:
                    harness.processIdentifier,
                rawStatus: 0
            ),
        ]
        let child = harness.makeLifecycle()
        child.startDeathObservation()
        if establishGroupAuthority {
            XCTAssertTrue(
                child
                    .establishIsolatedSessionAndDedicatedGroup(),
                file: file,
                line: line
            )
        }
        XCTAssertTrue(
            try! child.observeDeath(
                until:
                    try! PrimeSecureChildPhaseDeadline(
                        startUptimeNanoseconds: 0,
                        durationNanoseconds: 2_000
                    )
            ),
            file: file,
            line: line
        )
        switch child.reapAfterObservedDeath() {
        case let .reaped(observation):
            XCTAssertEqual(
                observation
                    .returnedProcessIdentifier,
                harness.processIdentifier,
                file: file,
                line: line
            )
        case let .mustFailStop(reason):
            XCTFail(
                "fixture reap unexpectedly failed: \(reason)",
                file: file,
                line: line
            )
        }
        return child
    }

    private func drainPipeToEOF(
        payload: Data,
        maximumByteCount: UInt64
    ) throws -> Capture.DrainSnapshot {
        var descriptors = [
            Int32(-1),
            Int32(-1),
        ]
        guard Darwin.pipe(&descriptors) == 0
        else {
            throw POSIXFailure(
                operation: "pipe",
                errorNumber: errno
            )
        }
        let readDescriptor = descriptors[0]
        let writeDescriptor = descriptors[1]
        var writerIsOpen = true
        defer {
            if writerIsOpen {
                _ = Darwin.close(
                    writeDescriptor
                )
            }
        }

        let drain =
            Capture.RawBoundedDrain(
                descriptor: readDescriptor,
                maximumByteCount:
                    maximumByteCount,
                chunkByteCount: 16
            )
        let group = DispatchGroup()
        drain.start(group: group)
        let written =
            payload.withUnsafeBytes {
                Darwin.write(
                    writeDescriptor,
                    $0.baseAddress,
                    $0.count
                )
            }
        guard written == payload.count
        else {
            throw POSIXFailure(
                operation: "write",
                errorNumber:
                    written < 0
                    ? errno
                    : EIO
            )
        }
        guard Darwin.close(
            writeDescriptor
        ) == 0
        else {
            throw POSIXFailure(
                operation: "close",
                errorNumber: errno
            )
        }
        writerIsOpen = false
        guard group.wait(
            timeout: .now() + .seconds(2)
        ) == .success
        else {
            drain.requestStop()
            throw POSIXFailure(
                operation: "drain_wait",
                errorNumber: ETIMEDOUT
            )
        }
        return drain.snapshot()
    }

    private func drainClosedReadDescriptor()
        throws -> Capture.DrainSnapshot
    {
        let group = DispatchGroup()
        DispatchQueue.global(
            qos: .utility
        ).sync {}

        var descriptors = [
            Int32(-1),
            Int32(-1),
        ]
        guard Darwin.pipe(&descriptors) == 0
        else {
            throw POSIXFailure(
                operation: "pipe",
                errorNumber: errno
            )
        }
        let closedReadDescriptor =
            Darwin.fcntl(
                descriptors[0],
                F_DUPFD,
                4_096
            )
        let duplicateErrno = errno
        _ = Darwin.close(descriptors[0])
        _ = Darwin.close(descriptors[1])
        guard closedReadDescriptor >= 0
        else {
            throw POSIXFailure(
                operation: "fcntl_F_DUPFD",
                errorNumber: duplicateErrno
            )
        }
        guard Darwin.close(
            closedReadDescriptor
        ) == 0
        else {
            throw POSIXFailure(
                operation: "close",
                errorNumber: errno
            )
        }

        let drain =
            Capture.RawBoundedDrain(
                descriptor:
                    closedReadDescriptor,
                maximumByteCount: 8,
                chunkByteCount: 8
            )
        drain.start(group: group)
        guard group.wait(
            timeout: .now() + .seconds(2)
        ) == .success
        else {
            drain.requestStop()
            throw POSIXFailure(
                operation: "drain_wait",
                errorNumber: ETIMEDOUT
            )
        }
        return drain.snapshot()
    }

    private func finishedEOFSnapshot()
        -> Capture.DrainSnapshot
    {
        Capture.DrainSnapshot(
            terminalReason: .endOfFile,
            data: Data(),
            totalByteCount: 0,
            overflowed: false,
            workerFinished: true,
            reachedEOF: true,
            readErrorNumber: 0,
            writeErrorNumber: 0,
            finalizationErrorNumber: 0,
            closeErrorNumber: 0,
            descriptorsClosed: true
        )
    }

    private struct POSIXFailure:
        Error,
        CustomStringConvertible
    {
        let operation: String
        let errorNumber: Int32

        var description: String {
            "\(operation) failed with errno \(errorNumber)"
        }
    }

    private struct SignalObservation:
        Equatable
    {
        let target:
            PrimeSecureChildSignalTarget
        let signal: PrimeSecureChildSignal
    }

    private final class Harness:
        @unchecked Sendable
    {
        let processIdentifier: Int32
        var nowValue: UInt64 = 10
        var deathNotifications:
            [UInt64?] = []
        var signalDeliveries:
            [PrimeSecureChildSignalDelivery] =
            []
        var waitResults:
            [PrimeSecureChildWaitResult] = []
        var queuedProcessGroupMembers:
            [[Int32]?] = []
        var processGroupIsEmpty = true

        private(set) var signals:
            [SignalObservation] = []
        private(set) var waitModes:
            [PrimeSecureChildWaitMode] = []
        private(set) var awaitedDeathDeadlines:
            [UInt64] = []
        private(set) var processGroupMemberObservations:
            [[Int32]?] = []
        private(set) var startDeathObservationCallCount =
            0
        private(set) var processGroupMembersCallCount =
            0
        private(set) var processGroupEmptyCallCount =
            0
        private(set) var advanceContainmentPollCount =
            0
        private(set) var cancelDeathObservationCallCount =
            0
        private(set) var returnedPIDReapCount = 0
        private(set) var operationLog:
            [String] = []

        init(processIdentifier: Int32) {
            self.processIdentifier =
                processIdentifier
        }

        func makeLifecycle() -> Lifecycle {
            Lifecycle(
                processIdentifier:
                    processIdentifier,
                operations:
                    PrimeSecureChildLifecycleOperations(
                        startDeathObservation: {
                            self.operationLog.append(
                                "start_death_observation"
                            )
                            self
                                .startDeathObservationCallCount
                                += 1
                        },
                        now: {
                            self.nowValue
                        },
                        awaitDeathNotification: {
                            deadline in
                            self.operationLog.append(
                                "await_death"
                            )
                            self.awaitedDeathDeadlines
                                .append(deadline)
                            guard !self
                                .deathNotifications
                                .isEmpty
                            else {
                                return nil
                            }
                            return self
                                .deathNotifications
                                .removeFirst()
                        },
                        sendSignal: {
                            target,
                            signal in
                            self.operationLog.append(
                                "signal_\(signal == .terminate ? "terminate" : "kill")"
                            )
                            self.signals.append(
                                SignalObservation(
                                    target: target,
                                    signal: signal
                                )
                            )
                            guard !self
                                .signalDeliveries
                                .isEmpty
                            else {
                                return .delivered
                            }
                            return self
                                .signalDeliveries
                                .removeFirst()
                        },
                        waitExactPID: {
                            mode in
                            self.operationLog.append(
                                "wait_exact_pid"
                            )
                            self.waitModes
                                .append(mode)
                            let result:
                                PrimeSecureChildWaitResult
                            if self.waitResults
                                .isEmpty
                            {
                                result =
                                    .stillRunning
                            } else {
                                result =
                                    self.waitResults
                                    .removeFirst()
                            }
                            if case .reaped =
                                result
                            {
                                self
                                    .returnedPIDReapCount
                                    += 1
                            }
                            return result
                        },
                        processGroupMembers: {
                            self.operationLog.append(
                                "process_group_members"
                            )
                            self
                                .processGroupMembersCallCount
                                += 1
                            let observation:
                                [Int32]?
                            if self
                                .queuedProcessGroupMembers
                                .isEmpty
                            {
                                observation = [
                                    self
                                        .processIdentifier,
                                ]
                            } else {
                                observation =
                                    self
                                    .queuedProcessGroupMembers
                                    .removeFirst()
                            }
                            self
                                .processGroupMemberObservations
                                .append(
                                    observation
                                )
                            return observation
                        },
                        processGroupIsEmpty: {
                            self.operationLog.append(
                                "process_group_empty"
                            )
                            self
                                .processGroupEmptyCallCount
                                += 1
                            return self
                                .processGroupIsEmpty
                        },
                        advanceContainmentPoll: {
                            self
                                .advanceContainmentPollCount
                                += 1
                        },
                        cancelDeathObservation: {
                            self.operationLog.append(
                                "cancel_death_observation"
                            )
                            self
                                .cancelDeathObservationCallCount
                                += 1
                        }
                    )
            )
        }
    }
}
