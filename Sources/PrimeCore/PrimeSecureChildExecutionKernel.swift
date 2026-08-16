// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

/// Internal composition boundary for the closed validation-fixture adapter.
/// Process mechanics remain exclusively in the existing Prime substrate and
/// fixture body; this type validates capability topology and projects the
/// contained outcome into typed evidence without emitting it.
enum PrimeSecureChildExecutionKernel {
    /// Internal compatibility outcome retained only inside the authorized
    /// execution-kernel type. The exported fixture result remains unchanged;
    /// raw terminal facts support typed evidence before API adaptation.
    struct RawOutcome {
        let fixtureResult:
            PrimeValidationWorkflowFixtureChildResult?
        let operationalFailureCode: String?
        let mode:
            PrimeValidationWorkflowFixtureChildMode
        let processIdentifier: Int32
        let appliedSpawnFlags: UInt16
        let sessionIdentifier: Int32
        let processGroupIdentifier: Int32
        let executable:
            PrimeSecureChildExecutableObservation
        let workingDirectoryJoin:
            PrimeSecureChildDirectoryJoinObservation
        let mappedExecutable:
            PrimeSecureChildMappedExecutableObservation
        let exactPIDWait:
            PrimeNativeNeuralGateExactPIDWaitObservation
        let completion: PrimeSecureChildCompletion
        let preReapProcessGroupMembers: [Int32]?
        let processGroupEmptyAfterReap: Bool
        let fixtureContractSatisfied: Bool
        let standardOutputPrefix: Data
        let standardErrorPrefix: Data
        let standardOutputDrain:
            PrimeSecureChildFileBackedDrainSnapshot
        let standardErrorDrain:
            PrimeSecureChildFileBackedDrainSnapshot
        let phaseDeadline:
            PrimeSecureChildPhaseDeadline
        let spawnReturnCode: Int32
        let spawnReturnedMonotonicNanoseconds:
            UInt64
        let deathObservedMonotonicNanoseconds:
            UInt64?
        let cleanupTimeline:
            PrimeSecureChildCleanupTimeline?
    }

    struct Result {
        private let executionClaim:
            PrimeTrustedSecureChildProcessCapture
            .Consumption.ExecutionClaim
        let rawOutcome:
            RawOutcome
        let evidence:
            PrimeSecureChildProcessEvidenceV1
        let diagnosticCanonicalData: Data

        init(
            executionClaim:
                PrimeTrustedSecureChildProcessCapture
                .Consumption.ExecutionClaim,
            rawOutcome: RawOutcome,
            evidence: PrimeSecureChildProcessEvidenceV1,
            diagnosticCanonicalData: Data
        ) {
            self.executionClaim = executionClaim
            self.rawOutcome = rawOutcome
            self.evidence = evidence
            self.diagnosticCanonicalData = diagnosticCanonicalData
        }

        var fixtureResult:
            PrimeValidationWorkflowFixtureChildResult?
        {
            rawOutcome.fixtureResult
        }

        var operationalFailureCode: String? {
            rawOutcome.operationalFailureCode
        }

        var cleanupTimeline:
            PrimeSecureChildCleanupTimeline?
        {
            rawOutcome.cleanupTimeline
        }
    }

    static func processEvidence(
        outcome: RawOutcome,
        leaseTelemetry:
            PrimeSecureChildLeaseRetention.Telemetry?
    ) -> PrimeSecureChildProcessEvidenceV1 {
        let deadlineLimitReached: Bool
        switch outcome.completion {
        case .wallClockLimit, .streamContainmentLimit:
            deadlineLimitReached = true
        case .exited, .signaled:
            deadlineLimitReached = false
        }
        let deadline =
            PrimeSecureChildProcessEvidenceV1.Deadline(
                startUptimeNanoseconds:
                    .observed(
                        outcome.phaseDeadline
                            .startUptimeNanoseconds
                    ),
                absoluteUptimeNanoseconds:
                    .observed(
                        outcome.phaseDeadline
                            .expiresAtUptimeNanoseconds
                    ),
                expiryObservedUptimeNanoseconds:
                    deadlineLimitReached
                    ? .unavailable(
                        .unsupportedByCurrentLifecycle
                    )
                    : .unavailable(.notApplicable),
                limitReached: deadlineLimitReached
            )
        let reap = outcome.exactPIDWait
        return PrimeSecureChildProcessEvidenceV1(
            role: .validationWorkflowFixture,
            phase:
                outcome.fixtureContractSatisfied
                ? .complete
                : .failed,
            operationalCode:
                operationalCode(outcome),
            spawn: .observed(
                .init(
                    processIdentifier:
                        outcome.processIdentifier,
                    spawnReturnCode:
                        outcome.spawnReturnCode,
                    appliedFlags:
                        outcome.appliedSpawnFlags,
                    sessionIdentifier:
                        outcome.sessionIdentifier,
                    processGroupIdentifier:
                        outcome.processGroupIdentifier,
                    suspendedBeforeIdentityProof: true
                )
            ),
            executableIdentity: .observed(
                executableIdentity(outcome.executable)
            ),
            workingDirectoryJoin: .observed(
                directoryJoin(outcome.workingDirectoryJoin)
            ),
            mappedExecutableJoin: .observed(
                mappedExecutableJoin(
                    outcome.mappedExecutable
                )
            ),
            deadline: .observed(deadline),
            completion: .observed(
                .init(outcome.completion)
            ),
            termAttempt:
                .unavailable(
                    .unsupportedByCurrentLifecycle
                ),
            killAttempt:
                .unavailable(
                    .unsupportedByCurrentLifecycle
                ),
            exactPIDReap: .observed(
                .init(
                    requestedProcessIdentifier:
                        reap.requestedProcessIdentifier,
                    returnedProcessIdentifier:
                        reap.returnedProcessIdentifier,
                    waitOptions: reap.waitOptions,
                    rawWaitStatus: reap.rawWaitStatus,
                    exitedNormally: reap.exitedNormally,
                    exitStatus: reap.exitStatus,
                    terminationSignal:
                        reap.terminationSignal,
                    coreDumped: reap.coreDumped,
                    childTerminationObserved:
                        reap.childTerminationObserved,
                    childReaped: reap.childReaped,
                    returnedUptimeNanoseconds:
                        reap.returnedMonotonicNanoseconds
                )
            ),
            processGroupEmpty: .observed(
                outcome.processGroupEmptyAfterReap
            ),
            standardOutput: stream(
                prefix: outcome.standardOutputPrefix,
                snapshot: outcome.standardOutputDrain
            ),
            standardError: stream(
                prefix: outcome.standardErrorPrefix,
                snapshot: outcome.standardErrorDrain
            ),
            lease: leaseTelemetry.map {
                .observed(.init($0))
            } ?? .unavailable(.leaseNotProvided)
        )
    }

    private static func operationalCode(
        _ outcome: RawOutcome
    ) -> PrimeSecureChildProcessEvidenceV1.OperationalCode {
        if outcome.operationalFailureCode != nil {
            return .operationalFailure
        }
        guard outcome.fixtureContractSatisfied else {
            return .fixtureContractRejected
        }
        switch outcome.completion {
        case let .exited(status):
            return status == 0
                ? .success
                : .childNonzeroExit
        case .signaled:
            return .childSignal
        case .wallClockLimit:
            return .wallClockLimit
        case .streamContainmentLimit:
            return .streamContainmentLimit
        }
    }

    private static func executableIdentity(
        _ value: PrimeSecureChildExecutableObservation
    ) -> PrimeSecureChildProcessEvidenceV1.ExecutableIdentity {
        .init(
            deviceID: value.deviceID,
            inode: value.inode,
            byteCount: value.byteCount,
            sha256: value.sha256,
            ownerUserID: value.ownerUserID,
            ownerGroupID: value.ownerGroupID,
            permissionMode: value.permissionMode,
            linkCount: value.linkCount,
            modificationTimeSeconds:
                value.modificationTimeSeconds,
            modificationTimeNanoseconds:
                value.modificationTimeNanoseconds,
            statusChangeTimeSeconds:
                value.statusChangeTimeSeconds,
            statusChangeTimeNanoseconds:
                value.statusChangeTimeNanoseconds
        )
    }

    private static func directoryJoin(
        _ value: PrimeSecureChildDirectoryJoinObservation
    ) -> PrimeSecureChildProcessEvidenceV1.DirectoryJoin {
        .init(
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

    private static func mappedExecutableJoin(
        _ value: PrimeSecureChildMappedExecutableObservation
    ) -> PrimeSecureChildProcessEvidenceV1.MappedExecutableJoin {
        .init(
            mappedExecutableAbsolutePath:
                value.mappedExecutableAbsolutePath,
            queryCount: value.queryCount,
            terminalErrno: value.terminalErrno,
            exactDescriptorJoinObserved:
                value.exactDescriptorJoinObserved
        )
    }

    private static func stream(
        prefix: Data,
        snapshot: PrimeSecureChildFileBackedDrainSnapshot
    ) -> PrimeSecureChildProcessEvidenceV1.Stream {
        .init(
            capturedPrefix: prefix,
            totalByteCount: snapshot.totalByteCount,
            overflowed: snapshot.overflowed,
            workerFinished: snapshot.workerFinished,
            descriptorsClosed: snapshot.descriptorsClosed,
            terminalReason: snapshot.terminalReason,
            reachedEOF: snapshot.reachedEOF,
            readErrorNumber: snapshot.readErrorNumber,
            writeErrorNumber: snapshot.writeErrorNumber,
            finalizationErrorNumber:
                snapshot.finalizationErrorNumber,
            closeErrorNumber: snapshot.closeErrorNumber
        )
    }
}
