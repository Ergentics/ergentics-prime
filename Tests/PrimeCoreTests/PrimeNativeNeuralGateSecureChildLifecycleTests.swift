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
        PrimeNativeNeuralGateSecureChildLifecycle

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
            child.cleanupRejectedCapture(),
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

        XCTAssertEqual(
            child.cleanupRejectedCapture(),
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
        harness.deathNotifications = [
            nil,
            103,
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
            child.cleanupRejectedCapture(),
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
                50
                    + Lifecycle
                    .signalGraceNanoseconds,
                50
                    + Lifecycle
                    .signalGraceNanoseconds,
            ]
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
    }

    func testObservedDeathAfterSIGTERMSuppressesSIGKILL() {
        let processIdentifier: Int32 = 4_104
        let harness = Harness(
            processIdentifier: processIdentifier
        )
        harness.deathNotifications = [
            104,
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
            child.cleanupRejectedCapture(),
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
            child.cleanupRejectedCapture(),
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
                    + Lifecycle
                    .signalGraceNanoseconds,
                75
                    + Lifecycle
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
            child.cleanupRejectedCapture(),
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
            snapshot.readErrorNumber,
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
            Capture.rejectedDrainDisposition(
                stdout: snapshot,
                stderr: finishedEOFSnapshot()
            ),
            .contained
        )
        XCTAssertEqual(
            child.cleanupRejectedCapture(),
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
        XCTAssertFalse(
            snapshot.workerFinished
                && snapshot.reachedEOF
                && snapshot.readErrorNumber
                    == 0
                && !snapshot.overflowed
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
            Capture.rejectedDrainDisposition(
                stdout: snapshot,
                stderr: finishedEOFSnapshot()
            ),
            .contained
        )
        XCTAssertEqual(
            child.cleanupRejectedCapture(),
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
                data: Data(),
                totalByteCount: 0,
                overflowed: false,
                workerFinished: false,
                reachedEOF: false,
                readErrorNumber: 0
            )

        XCTAssertEqual(
            Capture.rejectedDrainDisposition(
                stdout: active,
                stderr: finishedEOFSnapshot()
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
            child.cleanupRejectedCapture(),
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
            child.cleanupRejectedCapture(),
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
            child.observeDeath(
                untilNanoseconds: 2_000
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
            data: Data(),
            totalByteCount: 0,
            overflowed: false,
            workerFinished: true,
            reachedEOF: true,
            readErrorNumber: 0
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
                            self
                                .startDeathObservationCallCount
                                += 1
                        },
                        now: {
                            self.nowValue
                        },
                        awaitDeathNotification: {
                            deadline in
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
                            self
                                .cancelDeathObservationCallCount
                                += 1
                        }
                    )
            )
        }
    }
}
