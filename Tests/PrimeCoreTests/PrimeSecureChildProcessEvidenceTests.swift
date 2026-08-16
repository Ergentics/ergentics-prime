// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Dispatch
import Foundation
import XCTest
@testable import PrimeCore

final class PrimeSecureChildProcessEvidenceTests: XCTestCase {
    private typealias Evidence = PrimeSecureChildProcessEvidenceV1
    private typealias Observation<Value> = Evidence.Observation<Value>
        where Value: Equatable & Sendable

    func testPlanAdmissionRejectsUnsafeAndUnboundedInputs() throws {
        let plan = try PrimeSecureChildProcessPlanV1
            .validationWorkflowFixture(mode: .pass)

        XCTAssertEqual(plan.standardInputPolicy, .devNull)
        XCTAssertEqual(plan.orderedEnvironment.count, 0)
        XCTAssertEqual(plan.maximumWallNanoseconds, 10_000_000_000)
        XCTAssertEqual(plan.standardOutputMaximumByteCount, 65_536)
        XCTAssertEqual(plan.standardErrorMaximumByteCount, 65_536)
        XCTAssertEqual(
            try plan.argumentZero(
                physicalExecutableAbsolutePath:
                    "/private/tmp/PrimeValidationWorkflowFixtureChild"
            ),
            "/private/tmp/PrimeValidationWorkflowFixtureChild"
        )

        for unsafeExecutable in [
            "relative/tool",
            "/private/tmp/../tool",
            "/private//tmp/tool",
            "/private/tmp/tool\0suffix",
        ] {
            XCTAssertThrowsError(
                try plan.argumentZero(
                    physicalExecutableAbsolutePath: unsafeExecutable
                )
            )
        }
        for unsafeResult in [
            "relative/result",
            "/",
            "/private/tmp/",
            "/private/tmp/../result",
            "/private//tmp/result",
            "/private/tmp/result\\leaf",
        ] {
            XCTAssertThrowsError(
                try plan.exactArguments(
                    resultAbsolutePath: unsafeResult
                )
            )
        }
        let oversized = "/" + String(repeating: "a", count: 4_096)
        XCTAssertThrowsError(
            try plan.exactArguments(resultAbsolutePath: oversized)
        )

        let noResult = try PrimeSecureChildProcessPlanV1
            .validationWorkflowFixture(mode: .exitWithoutResult)
        XCTAssertThrowsError(
            try noResult.exactArguments(
                resultAbsolutePath: "/private/tmp/not-admitted"
            )
        )
        XCTAssertEqual(
            try noResult.exactArguments(resultAbsolutePath: ""),
            ["--mode", "exit-without-result"]
        )
    }

    func testTrustedCaptureIsExactlyOneShotUnderSequentialAndConcurrentCalls()
        throws
    {
        let plan = try PrimeSecureChildProcessPlanV1
            .validationWorkflowFixture(mode: .pass)
        let context = IdentityToken()
        let sequential = PrimeTrustedSecureChildProcessCapture(
            plan: plan,
            closedContext: context
        )
        let first = try sequential.consume()
        let firstClaim = try first.claimForExecution()
        XCTAssertTrue(firstClaim.plan === plan)
        XCTAssertTrue(firstClaim.retainsClosedContext(context))
        XCTAssertThrowsError(try first.claimForExecution()) { error in
            XCTAssertEqual(
                error as? PrimeTrustedSecureChildProcessCapture
                    .ConsumptionError,
                .alreadyClaimed
            )
        }
        XCTAssertThrowsError(try sequential.consume()) { error in
            XCTAssertEqual(
                error as? PrimeTrustedSecureChildProcessCapture
                    .ConsumptionError,
                .alreadyConsumed
            )
        }

        let concurrent = PrimeTrustedSecureChildProcessCapture(
            plan: plan,
            closedContext: context
        )
        let successes = LockedCounter()
        let failures = LockedCounter()
        DispatchQueue.concurrentPerform(iterations: 128) { _ in
            do {
                _ = try concurrent.consume()
                successes.increment()
            } catch {
                failures.increment()
            }
        }
        XCTAssertEqual(successes.value, 1)
        XCTAssertEqual(failures.value, 127)

        let claimCapture = PrimeTrustedSecureChildProcessCapture(
            plan: plan,
            closedContext: context
        )
        let consumption = try claimCapture.consume()
        let claimSuccesses = LockedCounter()
        let claimFailures = LockedCounter()
        let unexpectedClaimErrors = LockedCounter()
        DispatchQueue.concurrentPerform(iterations: 128) { _ in
            do {
                _ = try consumption.claimForExecution()
                claimSuccesses.increment()
            } catch let error as
                PrimeTrustedSecureChildProcessCapture.ConsumptionError
                where error == .alreadyClaimed
            {
                claimFailures.increment()
            } catch {
                unexpectedClaimErrors.increment()
            }
        }
        XCTAssertEqual(claimSuccesses.value, 1)
        XCTAssertEqual(claimFailures.value, 127)
        XCTAssertEqual(unexpectedClaimErrors.value, 0)
    }

    func testEvidenceKeepsUnavailableDistinctFromObservedFalse() {
        let observedFalse: Observation<Bool> = .observed(false)
        let unavailable: Observation<Bool> = .unavailable(.notObserved)

        XCTAssertNotEqual(observedFalse, unavailable)
        XCTAssertEqual(observedFalse.observedValue, false)
        XCTAssertNil(observedFalse.unavailableReason)
        XCTAssertNil(unavailable.observedValue)
        XCTAssertEqual(unavailable.unavailableReason, .notObserved)

        let falseEvidence = makeEvidence(processGroupEmpty: observedFalse)
        let unavailableEvidence = makeEvidence(
            processGroupEmpty: unavailable
        )
        XCTAssertThrowsError(
            try PrimeSecureChildDiagnosticProjection
                .canonicalData(for: falseEvidence)
        ) { error in
            XCTAssertEqual(
                error as? PrimeSecureChildDiagnosticProjection
                    .ProjectionError,
                .containmentUnproved
            )
        }
        XCTAssertThrowsError(
            try PrimeSecureChildDiagnosticProjection
                .canonicalData(for: unavailableEvidence)
        )
    }

    func testCompletionEvidenceCoversExitNonzeroAndSignal() throws {
        let exited = makeEvidence(
            operationalCode: .childNonzeroExit,
            completion: .observed(.exited(status: 23))
        )
        let exitEnvelope = try PrimeSecureChildDiagnosticProjection
            .envelope(for: exited)
        XCTAssertEqual(exitEnvelope.completion.kind, "exited")
        XCTAssertEqual(exitEnvelope.completion.status, 23)
        XCTAssertNil(exitEnvelope.completion.signal)

        let signaled = makeEvidence(
            operationalCode: .childSignal,
            completion: .observed(
                .signaled(signal: 9, coreDumped: true)
            )
        )
        let signalEnvelope = try PrimeSecureChildDiagnosticProjection
            .envelope(for: signaled)
        XCTAssertEqual(signalEnvelope.completion.kind, "signaled")
        XCTAssertNil(signalEnvelope.completion.status)
        XCTAssertEqual(signalEnvelope.completion.signal, 9)
        XCTAssertEqual(signalEnvelope.completion.coreDumped, true)

        let reachedLimit: Observation<Evidence.Deadline> = .observed(
            .init(
                startUptimeNanoseconds: .unavailable(.notObserved),
                absoluteUptimeNanoseconds: .unavailable(.notObserved),
                expiryObservedUptimeNanoseconds:
                    .unavailable(.unsupportedByCurrentLifecycle),
                limitReached: true
            )
        )
        let contradictions = [
            makeEvidence(
                operationalCode: .success,
                completion: .observed(
                    .signaled(signal: 9, coreDumped: false)
                )
            ),
            makeEvidence(
                operationalCode: .childNonzeroExit,
                completion: .observed(.exited(status: 0))
            ),
            makeEvidence(
                operationalCode: .childSignal,
                completion: .observed(.exited(status: 0))
            ),
            makeEvidence(
                operationalCode: .success,
                completion: .observed(.exited(status: 0)),
                exactPIDReap: .observed(
                    exactReap(
                        matching: .observed(.exited(status: 23))
                    )
                )
            ),
            makeEvidence(
                operationalCode: .childSignal,
                completion: .observed(
                    .signaled(signal: 9, coreDumped: false)
                ),
                exactPIDReap: .observed(
                    exactReap(
                        matching: .observed(
                            .signaled(signal: 9, coreDumped: true)
                        )
                    )
                )
            ),
            makeEvidence(
                operationalCode: .wallClockLimit,
                deadline: reachedLimit,
                completion: .observed(
                    .wallClockLimit(exitStatus: -1, signal: 15)
                ),
                exactPIDReap: .observed(
                    exactReap(
                        matching: .observed(
                            .signaled(signal: 9, coreDumped: false)
                        )
                    )
                )
            ),
            makeEvidence(
                operationalCode: .streamContainmentLimit,
                deadline: reachedLimit,
                completion: .observed(
                    .streamContainmentLimit(exitStatus: -1, signal: 15)
                ),
                exactPIDReap: .observed(
                    exactReap(
                        matching: .observed(
                            .signaled(signal: 9, coreDumped: false)
                        )
                    )
                )
            ),
        ]
        for contradiction in contradictions {
            XCTAssertThrowsError(
                try PrimeSecureChildDiagnosticProjection.canonicalData(
                    for: contradiction
                )
            ) { error in
                XCTAssertEqual(
                    error as? PrimeSecureChildDiagnosticProjection
                        .ProjectionError,
                    .invalidOperationalSemantics
                )
            }
        }
    }

    func testDeadlineEvidencePreservesTERMThenKILLAndSuppression()
        throws
    {
        let deadline = Evidence.Deadline(
            startUptimeNanoseconds: .observed(100),
            absoluteUptimeNanoseconds: .observed(200),
            expiryObservedUptimeNanoseconds: .observed(201),
            limitReached: true
        )
        let term = Evidence.SignalAttempt(
            signalNumber: 15,
            orderedOrdinal: 1,
            attemptedAtUptimeNanoseconds: 202,
            disposition: .delivered,
            errorNumber: 0
        )
        let kill = Evidence.SignalAttempt(
            signalNumber: 9,
            orderedOrdinal: 2,
            attemptedAtUptimeNanoseconds: 203,
            disposition: .suppressedBecauseAlreadyReaped,
            errorNumber: 0
        )
        let evidence = makeEvidence(
            phase: .complete,
            operationalCode: .wallClockLimit,
            deadline: .observed(deadline),
            completion: .observed(
                .wallClockLimit(exitStatus: -1, signal: 15)
            ),
            termAttempt: .observed(term),
            killAttempt: .observed(kill)
        )

        XCTAssertLessThan(
            term.attemptedAtUptimeNanoseconds,
            kill.attemptedAtUptimeNanoseconds
        )
        XCTAssertEqual(term.orderedOrdinal, 1)
        XCTAssertEqual(kill.orderedOrdinal, 2)
        XCTAssertEqual(kill.disposition, .suppressedBecauseAlreadyReaped)
        let projection = try PrimeSecureChildDiagnosticProjection
            .envelope(for: evidence)
        XCTAssertEqual(projection.deadline.limitReached, true)
        XCTAssertEqual(
            projection.deadline.termAttempt,
            "observed_delivered"
        )
        XCTAssertEqual(
            projection.deadline.killAttempt,
            "observed_suppressed_because_already_reaped"
        )

        func assertRejected(
            term candidateTerm: Evidence.SignalAttempt?
                = term,
            termUnavailableReason:
                Evidence.UnavailableReason? = nil,
            kill candidateKill: Evidence.SignalAttempt?
                = kill
        ) {
            let termObservation: Observation<Evidence.SignalAttempt> =
                candidateTerm.map { .observed($0) }
                ?? .unavailable(termUnavailableReason ?? .notObserved)
            let killObservation: Observation<Evidence.SignalAttempt> =
                candidateKill.map { .observed($0) }
                ?? .unavailable(.notObserved)
            XCTAssertThrowsError(
                try PrimeSecureChildDiagnosticProjection.canonicalData(
                    for: makeEvidence(
                        operationalCode: .wallClockLimit,
                        deadline: .observed(deadline),
                        completion: .observed(
                            .wallClockLimit(exitStatus: -1, signal: 15)
                        ),
                        termAttempt: termObservation,
                        killAttempt: killObservation
                    )
                )
            ) { error in
                XCTAssertEqual(
                    error as? PrimeSecureChildDiagnosticProjection
                        .ProjectionError,
                    .invalidSignalTimeline
                )
            }
        }

        assertRejected(
            term: .init(
                signalNumber: 15,
                orderedOrdinal: 2,
                attemptedAtUptimeNanoseconds: 202,
                disposition: .delivered,
                errorNumber: 0
            )
        )
        assertRejected(
            kill: .init(
                signalNumber: 9,
                orderedOrdinal: 2,
                attemptedAtUptimeNanoseconds: 201,
                disposition: .delivered,
                errorNumber: 0
            )
        )
        assertRejected(
            term: .init(
                signalNumber: 9,
                orderedOrdinal: 1,
                attemptedAtUptimeNanoseconds: 202,
                disposition: .delivered,
                errorNumber: 0
            )
        )
        assertRejected(
            kill: .init(
                signalNumber: 15,
                orderedOrdinal: 2,
                attemptedAtUptimeNanoseconds: 203,
                disposition: .delivered,
                errorNumber: 0
            )
        )
        assertRejected(
            kill: .init(
                signalNumber: 9,
                orderedOrdinal: 1,
                attemptedAtUptimeNanoseconds: 203,
                disposition: .delivered,
                errorNumber: 0
            )
        )
        assertRejected(
            term: .init(
                signalNumber: 15,
                orderedOrdinal: 1,
                attemptedAtUptimeNanoseconds: 0,
                disposition: .delivered,
                errorNumber: 0
            )
        )
        assertRejected(
            term: .init(
                signalNumber: 15,
                orderedOrdinal: 1,
                attemptedAtUptimeNanoseconds: 202,
                disposition: .delivered,
                errorNumber: 5
            )
        )
        assertRejected(
            term: .init(
                signalNumber: 15,
                orderedOrdinal: 1,
                attemptedAtUptimeNanoseconds: 202,
                disposition: .suppressedBecauseAlreadyReaped,
                errorNumber: 0
            ),
            kill: .init(
                signalNumber: 9,
                orderedOrdinal: 2,
                attemptedAtUptimeNanoseconds: 203,
                disposition: .delivered,
                errorNumber: 0
            )
        )
        assertRejected(
            kill: .init(
                signalNumber: 9,
                orderedOrdinal: 2,
                attemptedAtUptimeNanoseconds: 203,
                disposition: .suppressedBecauseAlreadyReaped,
                errorNumber: 5
            )
        )
        assertRejected(
            term: .init(
                signalNumber: 15,
                orderedOrdinal: 1,
                attemptedAtUptimeNanoseconds: 202,
                disposition: .failed,
                errorNumber: 0
            )
        )
        assertRejected(
            term: nil,
            termUnavailableReason: .unsupportedByCurrentLifecycle,
            kill: kill
        )
        assertRejected(
            term: term,
            termUnavailableReason: nil,
            kill: nil
        )

        let termOnlyExplicitlyUnavailableKill = makeEvidence(
            operationalCode: .wallClockLimit,
            deadline: .observed(deadline),
            completion: .observed(
                .wallClockLimit(exitStatus: -1, signal: 15)
            ),
            termAttempt: .observed(term),
            killAttempt: .unavailable(.unsupportedByCurrentLifecycle)
        )
        XCTAssertNoThrow(
            try PrimeSecureChildDiagnosticProjection.canonicalData(
                for: termOnlyExplicitlyUnavailableKill
            )
        )

        let contradictoryDeadline = Evidence.Deadline(
            startUptimeNanoseconds: .observed(100),
            absoluteUptimeNanoseconds: .observed(200),
            expiryObservedUptimeNanoseconds: .unavailable(.notApplicable),
            limitReached: false
        )
        XCTAssertThrowsError(
            try PrimeSecureChildDiagnosticProjection.canonicalData(
                for: makeEvidence(
                    operationalCode: .wallClockLimit,
                    deadline: .observed(contradictoryDeadline),
                    completion: .observed(
                        .wallClockLimit(exitStatus: -1, signal: 15)
                    )
                )
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeSecureChildDiagnosticProjection
                    .ProjectionError,
                .invalidOperationalSemantics
            )
        }

        let invalidDeadlines = [
            Evidence.Deadline(
                startUptimeNanoseconds: .observed(0),
                absoluteUptimeNanoseconds: .observed(200),
                expiryObservedUptimeNanoseconds: .observed(201),
                limitReached: true
            ),
            Evidence.Deadline(
                startUptimeNanoseconds: .observed(200),
                absoluteUptimeNanoseconds: .observed(200),
                expiryObservedUptimeNanoseconds: .observed(201),
                limitReached: true
            ),
            Evidence.Deadline(
                startUptimeNanoseconds: .observed(100),
                absoluteUptimeNanoseconds: .observed(200),
                expiryObservedUptimeNanoseconds: .observed(199),
                limitReached: true
            ),
        ]
        for invalidDeadline in invalidDeadlines {
            XCTAssertThrowsError(
                try PrimeSecureChildDiagnosticProjection.canonicalData(
                    for: makeEvidence(
                        operationalCode: .wallClockLimit,
                        deadline: .observed(invalidDeadline),
                        completion: .observed(
                            .wallClockLimit(exitStatus: -1, signal: 15)
                        ),
                        termAttempt: .observed(term),
                        killAttempt: .observed(kill)
                    )
                )
            ) { error in
                XCTAssertEqual(
                    error as? PrimeSecureChildDiagnosticProjection
                        .ProjectionError,
                    .invalidDeadlineSemantics
                )
            }
        }
        let earlyTerm = Evidence.SignalAttempt(
            signalNumber: 15,
            orderedOrdinal: 1,
            attemptedAtUptimeNanoseconds: 200,
            disposition: .delivered,
            errorNumber: 0
        )
        XCTAssertThrowsError(
            try PrimeSecureChildDiagnosticProjection.canonicalData(
                for: makeEvidence(
                    operationalCode: .wallClockLimit,
                    deadline: .observed(deadline),
                    completion: .observed(
                        .wallClockLimit(exitStatus: -1, signal: 15)
                    ),
                    termAttempt: .observed(earlyTerm),
                    killAttempt: .observed(kill)
                )
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeSecureChildDiagnosticProjection
                    .ProjectionError,
                .invalidDeadlineSemantics
            )
        }

        XCTAssertThrowsError(
            try PrimeSecureChildDiagnosticProjection.canonicalData(
                for: makeEvidence(
                    termAttempt: .unavailable(.leaseNotProvided),
                    killAttempt: .unavailable(.fullStreamNotHashed)
                )
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeSecureChildDiagnosticProjection
                    .ProjectionError,
                .invalidSignalTimeline
            )
        }
    }

    func testReapAndGroupFailuresFailStopWithoutProjection() {
        let wrongPIDReap = Evidence.ExactPIDReap(
            requestedProcessIdentifier: 41,
            returnedProcessIdentifier: 42,
            waitOptions: 0,
            rawWaitStatus: 0,
            exitedNormally: true,
            exitStatus: 0,
            terminationSignal: 0,
            coreDumped: false,
            childTerminationObserved: false,
            childReaped: false,
            returnedUptimeNanoseconds: 300
        )
        let nonpositivePIDReap = Evidence.ExactPIDReap(
            requestedProcessIdentifier: 0,
            returnedProcessIdentifier: 0,
            waitOptions: 0,
            rawWaitStatus: 0,
            exitedNormally: true,
            exitStatus: 0,
            terminationSignal: 0,
            coreDumped: false,
            childTerminationObserved: true,
            childReaped: true,
            returnedUptimeNanoseconds: 300
        )
        let zeroTimeReap = Evidence.ExactPIDReap(
            requestedProcessIdentifier: 41,
            returnedProcessIdentifier: 41,
            waitOptions: 0,
            rawWaitStatus: 0,
            exitedNormally: true,
            exitStatus: 0,
            terminationSignal: 0,
            coreDumped: false,
            childTerminationObserved: true,
            childReaped: true,
            returnedUptimeNanoseconds: 0
        )
        func injectedReap(
            waitOptions: Int32 = 0,
            exitedNormally: Bool = true,
            exitStatus: Int32 = 0,
            terminationSignal: Int32 = 0,
            coreDumped: Bool = false
        ) -> Evidence.ExactPIDReap {
            .init(
                requestedProcessIdentifier: 41,
                returnedProcessIdentifier: 41,
                waitOptions: waitOptions,
                rawWaitStatus: 0,
                exitedNormally: exitedNormally,
                exitStatus: exitStatus,
                terminationSignal: terminationSignal,
                coreDumped: coreDumped,
                childTerminationObserved: true,
                childReaped: true,
                returnedUptimeNanoseconds: 300
            )
        }
        func reapMatchingRawStatus(
            _ rawWaitStatus: Int32
        ) -> Evidence.ExactPIDReap {
            let signal = rawWaitStatus & 0x7f
            let exitedNormally = signal == 0
            return .init(
                requestedProcessIdentifier: 41,
                returnedProcessIdentifier: 41,
                waitOptions: 0,
                rawWaitStatus: rawWaitStatus,
                exitedNormally: exitedNormally,
                exitStatus: exitedNormally
                    ? (rawWaitStatus >> 8) & 0xff
                    : -1,
                terminationSignal: signal,
                coreDumped: rawWaitStatus & 0x80 != 0,
                childTerminationObserved: true,
                childReaped: true,
                returnedUptimeNanoseconds: 300
            )
        }
        let nonblockingExactReap = injectedReap(
            waitOptions:
                PrimeSecureChildWaitMode
                .nonblockingContainmentProbe.darwinOptions
        )
        XCTAssertNoThrow(
            try PrimeSecureChildDiagnosticProjection.canonicalData(
                for: makeEvidence(
                    exactPIDReap: .observed(nonblockingExactReap)
                )
            )
        )
        let candidates = [
            makeEvidence(exactPIDReap: .observed(wrongPIDReap)),
            makeEvidence(exactPIDReap: .observed(nonpositivePIDReap)),
            makeEvidence(exactPIDReap: .observed(zeroTimeReap)),
            makeEvidence(
                exactPIDReap: .observed(injectedReap(waitOptions: 2))
            ),
            makeEvidence(
                exactPIDReap: .observed(
                    injectedReap(exitedNormally: false)
                )
            ),
            makeEvidence(
                exactPIDReap: .observed(injectedReap(exitStatus: 1))
            ),
            makeEvidence(
                exactPIDReap: .observed(
                    injectedReap(terminationSignal: 9)
                )
            ),
            makeEvidence(
                exactPIDReap: .observed(injectedReap(coreDumped: true))
            ),
            makeEvidence(
                exactPIDReap: .observed(reapMatchingRawStatus(-1))
            ),
            makeEvidence(
                exactPIDReap: .observed(
                    reapMatchingRawStatus(0x0001_0000)
                )
            ),
            makeEvidence(
                exactPIDReap: .observed(
                    reapMatchingRawStatus(0x137f)
                )
            ),
            makeEvidence(
                exactPIDReap: .observed(
                    reapMatchingRawStatus(0xffff)
                )
            ),
            makeEvidence(
                exactPIDReap: .observed(
                    reapMatchingRawStatus(0x0080)
                )
            ),
            makeEvidence(
                exactPIDReap: .observed(
                    reapMatchingRawStatus(0x0109)
                )
            ),
            makeEvidence(processGroupEmpty: .observed(false)),
            makeEvidence(exactPIDReap: .unavailable(.containmentUnproved)),
            makeEvidence(processGroupEmpty: .unavailable(.notObserved)),
        ]
        for candidate in candidates {
            XCTAssertThrowsError(
                try PrimeSecureChildDiagnosticProjection
                    .canonicalData(for: candidate)
            ) { error in
                XCTAssertEqual(
                    error as? PrimeSecureChildDiagnosticProjection
                        .ProjectionError,
                    .containmentUnproved
                )
            }
        }
    }

    func testOverflowUsesCapturedPrefixDigestAndUnavailableFullDigest()
        throws
    {
        let prefix = Data("bounded-prefix".utf8)
        let stream = makeStream(
            data: prefix,
            totalByteCount: 100_000,
            overflowed: true
        )
        XCTAssertEqual(
            stream.capturedPrefixSHA256,
            PrimeSHA256.hexDigest(of: prefix)
        )
        XCTAssertEqual(stream.capturedPrefixByteCount, UInt64(prefix.count))
        XCTAssertEqual(stream.observedTotalByteCount, 100_000)
        XCTAssertEqual(
            stream.fullStreamSHA256,
            .unavailable(.fullStreamNotHashed)
        )

        let evidence = makeEvidence(standardOutput: stream)
        let envelope = try PrimeSecureChildDiagnosticProjection
            .envelope(for: evidence)
        XCTAssertTrue(envelope.streams.standardOutput.overflowed)
        XCTAssertEqual(
            envelope.streams.standardOutput.fullStreamSHA256,
            "unavailable_full_stream_not_hashed"
        )
        XCTAssertNotEqual(
            envelope.streams.standardOutput.fullStreamSHA256,
            envelope.streams.standardOutput.capturedPrefixSHA256
        )

        let falseOverflow = makeStream(
            data: prefix,
            totalByteCount: UInt64(prefix.count),
            overflowed: true
        )
        let missingCleanBytes = makeStream(
            data: prefix,
            totalByteCount: UInt64(prefix.count + 1),
            overflowed: false
        )
        for contradiction in [falseOverflow, missingCleanBytes] {
            XCTAssertThrowsError(
                try PrimeSecureChildDiagnosticProjection.canonicalData(
                    for: makeEvidence(standardOutput: contradiction)
                )
            ) { error in
                XCTAssertEqual(
                    error as? PrimeSecureChildDiagnosticProjection
                        .ProjectionError,
                    .invalidStreamSemantics
                )
            }
        }
    }

    func testTerminalStreamErrorsRemainTypedWithoutClaimingEOF()
        throws
    {
        let readError = makeStream(
            data: Data("prefix".utf8),
            totalByteCount: 6,
            terminalReason: .readError,
            reachedEOF: false,
            readErrorNumber: 5
        )
        let finalizeError = makeStream(
            data: Data("other".utf8),
            totalByteCount: 5,
            terminalReason: .writeOrFinalizationError,
            reachedEOF: false,
            finalizationErrorNumber: 28
        )
        let evidence = makeEvidence(
            phase: .failed,
            operationalCode: .operationalFailure,
            standardOutput: readError,
            standardError: finalizeError
        )
        let envelope = try PrimeSecureChildDiagnosticProjection
            .envelope(for: evidence)

        XCTAssertFalse(envelope.streams.standardOutput.reachedEOF)
        XCTAssertEqual(envelope.streams.standardOutput.readErrno, 5)
        XCTAssertEqual(
            envelope.streams.standardOutput.terminalReason,
            "read_error"
        )
        XCTAssertFalse(envelope.streams.standardError.reachedEOF)
        XCTAssertEqual(
            envelope.streams.standardError.finalizationErrno,
            28
        )
        XCTAssertEqual(
            envelope.streams.standardError.terminalReason,
            "write_or_finalization_error"
        )

        XCTAssertThrowsError(
            try PrimeSecureChildDiagnosticProjection.canonicalData(
                for: makeEvidence(
                    operationalCode: .success,
                    standardOutput: readError
                )
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeSecureChildDiagnosticProjection
                    .ProjectionError,
                .invalidOperationalSemantics
            )
        }

        let contradictoryEOF = makeStream(
            data: Data("bad".utf8),
            totalByteCount: 3,
            terminalReason: .endOfFile,
            reachedEOF: true,
            closeErrorNumber: 9
        )
        XCTAssertThrowsError(
            try PrimeSecureChildDiagnosticProjection.canonicalData(
                for: makeEvidence(standardOutput: contradictoryEOF)
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeSecureChildDiagnosticProjection
                    .ProjectionError,
                .invalidStreamSemantics
            )
        }

        let incoherentErrorStreams = [
            makeStream(
                data: Data("negative-read".utf8),
                terminalReason: .readError,
                reachedEOF: false,
                readErrorNumber: -5
            ),
            makeStream(
                data: Data("negative-finalization".utf8),
                terminalReason: .writeOrFinalizationError,
                reachedEOF: false,
                finalizationErrorNumber: -28
            ),
            makeStream(
                data: Data("missing-write-error".utf8),
                terminalReason: .writeOrFinalizationError,
                reachedEOF: false
            ),
            makeStream(
                data: Data("negative-cleanup-close".utf8),
                terminalReason: .cleanupStop,
                reachedEOF: false,
                closeErrorNumber: -9
            ),
        ]
        for incoherent in incoherentErrorStreams {
            XCTAssertThrowsError(
                try PrimeSecureChildDiagnosticProjection.canonicalData(
                    for: makeEvidence(
                        phase: .failed,
                        operationalCode: .operationalFailure,
                        standardOutput: incoherent
                    )
                )
            ) { error in
                XCTAssertEqual(
                    error as? PrimeSecureChildDiagnosticProjection
                        .ProjectionError,
                    .invalidStreamSemantics
                )
            }
        }
    }

    func testActiveDrainOrOpenDescriptorCannotProject() {
        let active = makeStream(
            data: Data(),
            totalByteCount: 0,
            workerFinished: false,
            descriptorsClosed: false,
            terminalReason: .active,
            reachedEOF: false
        )
        let descriptorOpen = makeStream(
            data: Data(),
            totalByteCount: 0,
            workerFinished: true,
            descriptorsClosed: false,
            terminalReason: .endOfFile,
            reachedEOF: true
        )
        for candidate in [active, descriptorOpen] {
            XCTAssertThrowsError(
                try PrimeSecureChildDiagnosticProjection.canonicalData(
                    for: makeEvidence(standardOutput: candidate)
                )
            ) { error in
                XCTAssertEqual(
                    error as? PrimeSecureChildDiagnosticProjection
                        .ProjectionError,
                    .drainUnsettled
                )
            }
        }
    }

    func testDiagnosticProjectionIsCanonicalBoundedAndAllowlisted()
        throws
    {
        let evidence = makeEvidence(
            spawn: .observed(
                .init(
                    processIdentifier: 91_234,
                    spawnReturnCode: 0,
                    appliedFlags: 0,
                    sessionIdentifier: 91_234,
                    processGroupIdentifier: 91_234,
                    suspendedBeforeIdentityProof: true
                )
            ),
            mappedExecutableJoin: .observed(
                .init(
                    mappedExecutableAbsolutePath:
                        "/private/secret/executable",
                    queryCount: 1,
                    terminalErrno: 0,
                    exactDescriptorJoinObserved: true
                )
            )
        )
        let data = try PrimeSecureChildDiagnosticProjection
            .canonicalData(for: evidence)
        XCTAssertLessThanOrEqual(data.count, 4_096)
        XCTAssertFalse(data.contains(0x0a))
        XCTAssertFalse(data.contains(0x0d))

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        XCTAssertEqual(
            Set(object.keys),
            Set([
                "schema", "role", "phase", "operational_code",
                "completion", "deadline", "containment", "streams",
                "diagnostic_channel", "scientific_outcome",
            ])
        )
        XCTAssertEqual(object["scientific_outcome"] as? String,
                       "not_established")
        XCTAssertEqual(object["diagnostic_channel"] as? String,
                       "neutral_layer_a")

        let text = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertFalse(text.contains("91234"))
        XCTAssertFalse(text.contains("/private/secret/executable"))
        XCTAssertFalse(text.contains("PATH="))
        XCTAssertFalse(text.contains("raw_standard_error"))
        let decoded = try PrimeCanonicalJSON.decode(
            PrimeSecureChildDiagnosticEnvelopeV1.self,
            from: data
        )
        XCTAssertEqual(try PrimeCanonicalJSON.encode(decoded), data)
    }

    func testLeaseSeamRetainsOnlyExternallyOwnedTelemetry() {
        var capability: FalseClaimingLeaseToken? =
            FalseClaimingLeaseToken()
        weak let weakCapability = capability
        var retention: PrimeSecureChildLeaseRetention? =
            PrimeSecureChildLeaseRetention(
                externallyOwnedCapability: capability!
            )

        capability = nil
        XCTAssertNotNil(weakCapability)
        XCTAssertTrue(
            retention!.retainsExternallyOwnedCapability(weakCapability!)
        )
        let telemetry = retention!.telemetry
        XCTAssertEqual(telemetry.scope, .cooperatingHostPathLocal)
        XCTAssertTrue(telemetry.advisory)
        XCTAssertTrue(telemetry.ownerMustRemainLive)
        XCTAssertFalse(telemetry.childLifetimeContinuityEstablished)
        XCTAssertFalse(telemetry.mlxDeviceIdentityEstablished)
        XCTAssertFalse(telemetry.durableEvidenceEstablished)

        let observation = Evidence.LeaseObservation(telemetry)
        XCTAssertEqual(observation.scope, .cooperatingHostPathLocal)
        XCTAssertFalse(observation.childLifetimeContinuityEstablished)
        XCTAssertFalse(observation.mlxDeviceIdentityEstablished)
        XCTAssertFalse(observation.durableEvidenceEstablished)
        XCTAssertTrue(weakCapability!.claimsChildLifetimeContinuity)
        XCTAssertTrue(weakCapability!.claimsMLXDeviceIdentity)
        XCTAssertTrue(weakCapability!.claimsDurableEvidence)
        retention = nil
        XCTAssertNil(weakCapability)
    }

    func testFixtureAdapterMapsAllNineModesWithoutPublicGenericAuthority()
        throws
    {
        XCTAssertEqual(
            PrimeValidationWorkflowFixtureChildMode.allCases.count,
            9
        )
        let resultPath = "/private/tmp/fixture-result-v1.txt"
        let physicalExecutable =
            "/private/tmp/PrimeValidationWorkflowFixtureChild"

        for mode in PrimeValidationWorkflowFixtureChildMode.allCases {
            let plan = try PrimeSecureChildProcessPlanV1
                .validationWorkflowFixture(mode: mode)
            XCTAssertEqual(plan.validationWorkflowFixtureMode, mode)
            XCTAssertEqual(plan.orderedEnvironment.count, 0)
            XCTAssertEqual(plan.standardInputPolicy, .devNull)
            XCTAssertEqual(plan.standardOutputMaximumByteCount, 65_536)
            XCTAssertEqual(plan.standardErrorMaximumByteCount, 65_536)

            let arguments = try plan.exactArguments(
                resultAbsolutePath:
                    mode == .exitWithoutResult ? "" : resultPath
            )
            XCTAssertEqual(Array(arguments.prefix(2)), ["--mode", mode.rawValue])
            XCTAssertEqual(
                arguments.contains("--result-path"),
                mode != .exitWithoutResult
            )
            XCTAssertEqual(
                try plan.argumentZero(
                    physicalExecutableAbsolutePath: physicalExecutable
                ),
                mode == .logicalArgumentZero
                    ? "swift-build"
                    : physicalExecutable
            )
            XCTAssertEqual(
                plan.maximumWallNanoseconds,
                mode == .hang || mode == .descendantRetainsStreams
                    ? 1_000_000_000
                    : 10_000_000_000
            )
        }
    }

    private func makeEvidence(
        phase: Evidence.Phase = .complete,
        operationalCode: Evidence.OperationalCode = .success,
        spawn: Observation<Evidence.Spawn> = .unavailable(.notObserved),
        mappedExecutableJoin: Observation<Evidence.MappedExecutableJoin> =
            .unavailable(.notObserved),
        deadline: Observation<Evidence.Deadline> =
            .observed(
                .init(
                    startUptimeNanoseconds: .unavailable(.notObserved),
                    absoluteUptimeNanoseconds: .unavailable(.notObserved),
                    expiryObservedUptimeNanoseconds:
                        .unavailable(.notApplicable),
                    limitReached: false
                )
            ),
        completion: Observation<Evidence.Completion> =
            .observed(.exited(status: 0)),
        termAttempt: Observation<Evidence.SignalAttempt> =
            .unavailable(.notApplicable),
        killAttempt: Observation<Evidence.SignalAttempt> =
            .unavailable(.notApplicable),
        exactPIDReap: Observation<Evidence.ExactPIDReap>? = nil,
        processGroupEmpty: Observation<Bool> = .observed(true),
        standardOutput: Evidence.Stream? = nil,
        standardError: Evidence.Stream? = nil,
        lease: Observation<Evidence.LeaseObservation> =
            .unavailable(.leaseNotProvided)
    ) -> Evidence {
        Evidence(
            role: .validationWorkflowFixture,
            phase: phase,
            operationalCode: operationalCode,
            spawn: spawn,
            executableIdentity: .unavailable(.notObserved),
            workingDirectoryJoin: .unavailable(.notObserved),
            mappedExecutableJoin: mappedExecutableJoin,
            deadline: deadline,
            completion: completion,
            termAttempt: termAttempt,
            killAttempt: killAttempt,
            exactPIDReap: exactPIDReap
                ?? .observed(exactReap(matching: completion)),
            processGroupEmpty: processGroupEmpty,
            standardOutput: standardOutput ?? makeStream(),
            standardError: standardError ?? makeStream(),
            lease: lease
        )
    }

    private func exactReap(
        matching completion: Observation<Evidence.Completion> =
            .observed(.exited(status: 0))
    ) -> Evidence.ExactPIDReap {
        let rawWaitStatus: Int32
        switch completion {
        case .unavailable:
            rawWaitStatus = 0
        case let .observed(.exited(status)):
            rawWaitStatus = (status & 0xff) << 8
        case let .observed(.signaled(signal, coreDumped)):
            rawWaitStatus = signal | (coreDumped ? 0x80 : 0)
        case let .observed(.wallClockLimit(exitStatus, signal)),
             let .observed(.streamContainmentLimit(exitStatus, signal)):
            rawWaitStatus = signal == 0
                ? (exitStatus & 0xff) << 8
                : signal
        }
        let derivedSignal = rawWaitStatus & 0x7f
        let exitedNormally = derivedSignal == 0
        return .init(
            requestedProcessIdentifier: 41,
            returnedProcessIdentifier: 41,
            waitOptions: 0,
            rawWaitStatus: rawWaitStatus,
            exitedNormally: exitedNormally,
            exitStatus: exitedNormally
                ? (rawWaitStatus >> 8) & 0xff
                : -1,
            terminationSignal: derivedSignal,
            coreDumped: rawWaitStatus & 0x80 != 0,
            childTerminationObserved: true,
            childReaped: true,
            returnedUptimeNanoseconds: 300
        )
    }

    private func makeStream(
        data: Data = Data("complete".utf8),
        totalByteCount: UInt64? = nil,
        overflowed: Bool = false,
        workerFinished: Bool = true,
        descriptorsClosed: Bool = true,
        terminalReason: Evidence.StreamTerminalReason = .endOfFile,
        reachedEOF: Bool = true,
        readErrorNumber: Int32 = 0,
        writeErrorNumber: Int32 = 0,
        finalizationErrorNumber: Int32 = 0,
        closeErrorNumber: Int32 = 0
    ) -> Evidence.Stream {
        .init(
            capturedPrefix: data,
            totalByteCount: totalByteCount ?? UInt64(data.count),
            overflowed: overflowed,
            workerFinished: workerFinished,
            descriptorsClosed: descriptorsClosed,
            terminalReason: terminalReason,
            reachedEOF: reachedEOF,
            readErrorNumber: readErrorNumber,
            writeErrorNumber: writeErrorNumber,
            finalizationErrorNumber: finalizationErrorNumber,
            closeErrorNumber: closeErrorNumber
        )
    }

    private final class IdentityToken {}

    private final class FalseClaimingLeaseToken {
        let claimsChildLifetimeContinuity = true
        let claimsMLXDeviceIdentity = true
        let claimsDurableEvidence = true
    }

    private final class LockedCounter: @unchecked Sendable {
        private let lock = NSLock()
        private var storage = 0

        var value: Int {
            lock.lock()
            defer { lock.unlock() }
            return storage
        }

        func increment() {
            lock.lock()
            storage += 1
            lock.unlock()
        }
    }
}
