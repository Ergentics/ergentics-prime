import Darwin
import XCTest
@testable import PrimeCore

final class PrimeSupervisorPolicyTests:
    XCTestCase
{
    func testGroundedRequiresNormalZeroExit() {
        XCTAssertEqual(
            disposition(
                candidate: .grounded
            ),
            .promoteGrounded
        )
        XCTAssertEqual(
            disposition(
                kind: .uncaughtSignal,
                status: 9,
                candidate: .grounded
            ),
            .publishExecutorAbstain
        )
        XCTAssertEqual(
            disposition(
                status: 1,
                candidate: .grounded
            ),
            .publishExecutorAbstain
        )
    }

    func testTimeoutDominatesEveryCandidate() {
        for candidate in [
            PrimeWorkerCandidateKind.grounded,
            .abstain,
            .missing,
            .invalid,
        ] {
            XCTAssertEqual(
                disposition(
                    timedOut: true,
                    candidate: candidate
                ),
                .publishTimeLimitAbstain
            )
        }
    }

    func testMissingInvalidAndWorkerAbstainAreDistinct() {
        XCTAssertEqual(
            disposition(candidate: .missing),
            .publishExecutorAbstain
        )
        XCTAssertEqual(
            disposition(candidate: .invalid),
            .publishContractAbstain
        )
        XCTAssertEqual(
            disposition(candidate: .abstain),
            .publishWorkerAbstain
        )
    }

    func testUnobservedTerminationWithholdsFinalReceipt() {
        XCTAssertEqual(
            disposition(
                terminationObserved: false,
                timedOut: true,
                candidate: .grounded
            ),
            .withholdFinalReceipt
        )
    }

    func testBoundedSignalEscalationWithholdsFinalReceiptWhenSIGKILLIsUnobserved() {
        let processIdentifier: Int32 = 41_337
        let graceMilliseconds = 10_000
        var deliveredSignals: [
            (processIdentifier: Int32, signal: Int32)
        ] = []
        var boundedWaits: [Int] = []

        let outcome =
            PrimeProcessTermination
                .escalateAfterTimeout(
                    processIdentifier:
                        processIdentifier,
                    graceMilliseconds:
                        graceMilliseconds,
                    waitForTermination: {
                        milliseconds in
                        boundedWaits.append(milliseconds)
                        return false
                    },
                    sendSignal: {
                        observedProcessIdentifier,
                        signal in
                        deliveredSignals.append(
                            (
                                observedProcessIdentifier,
                                signal
                            )
                        )
                        return PrimeSignalDelivery(
                            signal: signal,
                            result: 0,
                            errorNumber: 0
                        )
                    }
                )

        XCTAssertEqual(
            deliveredSignals.map {
                $0.processIdentifier
            },
            [processIdentifier, processIdentifier]
        )
        XCTAssertEqual(
            deliveredSignals.map {
                $0.signal
            },
            [SIGTERM, SIGKILL]
        )
        XCTAssertEqual(
            boundedWaits,
            [graceMilliseconds, graceMilliseconds]
        )
        XCTAssertEqual(
            outcome,
            .unobservedAfterSIGKILL(
                term: PrimeSignalDelivery(
                    signal: SIGTERM,
                    result: 0,
                    errorNumber: 0
                ),
                kill: PrimeSignalDelivery(
                    signal: SIGKILL,
                    result: 0,
                    errorNumber: 0
                )
            )
        )
        XCTAssertFalse(outcome.terminationObserved)
        XCTAssertEqual(
            disposition(
                terminationObserved:
                    outcome.terminationObserved,
                timedOut: true,
                kind: .uncaughtSignal,
                status: SIGKILL,
                candidate: .grounded
            ),
            .withholdFinalReceipt
        )
    }

    private func disposition(
        terminationObserved: Bool = true,
        timedOut: Bool = false,
        kind: PrimeWorkerTerminationKind = .exit,
        status: Int32 = 0,
        candidate: PrimeWorkerCandidateKind
    ) -> PrimeSupervisorDisposition {
        PrimeSupervisorPolicy.disposition(
            for: PrimeSupervisorObservation(
                terminationObserved:
                    terminationObserved,
                hardTimeoutObserved: timedOut,
                terminationKind: kind,
                terminationStatus: status,
                candidate: candidate
            )
        )
    }
}
