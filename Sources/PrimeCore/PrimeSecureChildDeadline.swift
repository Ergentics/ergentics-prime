// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Dispatch

enum PrimeSecureChildDeadlineError:
    Error,
    Equatable,
    Sendable
{
    case zeroDuration
    case durationOverflow
    case endpointOverflow
    case reservedEndpoint
    case clockRegression(
        observedUptimeNanoseconds: UInt64,
        notBeforeUptimeNanoseconds: UInt64
    )
}

/// Checked monotonic arithmetic for one absolute deadline.
///
/// `UInt64.max` is rejected because Dispatch uses it as a practical
/// distant-future boundary. No constructor saturates arithmetic.
struct PrimeSecureChildAbsoluteDeadline:
    Equatable,
    Sendable
{
    static let nanosecondsPerSecond:
        UInt64 = 1_000_000_000

    let startUptimeNanoseconds: UInt64
    let expiresAtUptimeNanoseconds: UInt64

    init(
        startUptimeNanoseconds: UInt64,
        durationNanoseconds: UInt64
    ) throws {
        guard durationNanoseconds > 0 else {
            throw PrimeSecureChildDeadlineError
                .zeroDuration
        }
        let endpoint =
            startUptimeNanoseconds
            .addingReportingOverflow(
                durationNanoseconds
            )
        guard !endpoint.overflow else {
            throw PrimeSecureChildDeadlineError
                .endpointOverflow
        }
        guard endpoint.partialValue
                != UInt64.max
        else {
            throw PrimeSecureChildDeadlineError
                .reservedEndpoint
        }
        self.startUptimeNanoseconds =
            startUptimeNanoseconds
        expiresAtUptimeNanoseconds =
            endpoint.partialValue
    }

    init(
        startUptimeNanoseconds: UInt64,
        durationSeconds: UInt64
    ) throws {
        guard durationSeconds > 0 else {
            throw PrimeSecureChildDeadlineError
                .zeroDuration
        }
        let duration =
            durationSeconds
            .multipliedReportingOverflow(
                by: Self.nanosecondsPerSecond
            )
        guard !duration.overflow else {
            throw PrimeSecureChildDeadlineError
                .durationOverflow
        }
        try self.init(
            startUptimeNanoseconds:
                startUptimeNanoseconds,
            durationNanoseconds:
                duration.partialValue
        )
    }

    var dispatchTime: DispatchTime {
        DispatchTime(
            uptimeNanoseconds:
                expiresAtUptimeNanoseconds
        )
    }

    func requireNonregressingObservation(
        _ observedUptimeNanoseconds: UInt64,
        notBefore priorUptimeNanoseconds:
            UInt64? = nil
    ) throws {
        let lowerBound =
            priorUptimeNanoseconds
            ?? startUptimeNanoseconds
        guard lowerBound
                >= startUptimeNanoseconds,
              observedUptimeNanoseconds
                >= lowerBound
        else {
            throw PrimeSecureChildDeadlineError
                .clockRegression(
                    observedUptimeNanoseconds:
                        observedUptimeNanoseconds,
                    notBeforeUptimeNanoseconds:
                        max(
                            lowerBound,
                            startUptimeNanoseconds
                        )
                )
        }
    }

    func isStrictlyBeforeExpiration(
        _ observedUptimeNanoseconds: UInt64,
        notBefore priorUptimeNanoseconds:
            UInt64? = nil
    ) throws -> Bool {
        try requireNonregressingObservation(
            observedUptimeNanoseconds,
            notBefore: priorUptimeNanoseconds
        )
        return observedUptimeNanoseconds
            < expiresAtUptimeNanoseconds
    }

    func isAtOrBeforeExpiration(
        _ observedUptimeNanoseconds: UInt64,
        notBefore priorUptimeNanoseconds:
            UInt64? = nil
    ) throws -> Bool {
        try requireNonregressingObservation(
            observedUptimeNanoseconds,
            notBefore: priorUptimeNanoseconds
        )
        return observedUptimeNanoseconds
            <= expiresAtUptimeNanoseconds
    }
}

/// Phase-success authority for work governed by one absolute deadline.
///
/// Starting new work at the endpoint is forbidden. A completion observed
/// exactly at the endpoint remains timely.
struct PrimeSecureChildPhaseDeadline:
    Equatable,
    Sendable
{
    let absolute: PrimeSecureChildAbsoluteDeadline

    init(
        startUptimeNanoseconds: UInt64,
        durationNanoseconds: UInt64
    ) throws {
        absolute =
            try PrimeSecureChildAbsoluteDeadline(
                startUptimeNanoseconds:
                    startUptimeNanoseconds,
                durationNanoseconds:
                    durationNanoseconds
            )
    }

    init(
        startUptimeNanoseconds: UInt64,
        durationSeconds: UInt64
    ) throws {
        absolute =
            try PrimeSecureChildAbsoluteDeadline(
                startUptimeNanoseconds:
                    startUptimeNanoseconds,
                durationSeconds:
                    durationSeconds
            )
    }

    var startUptimeNanoseconds: UInt64 {
        absolute.startUptimeNanoseconds
    }

    var expiresAtUptimeNanoseconds: UInt64 {
        absolute.expiresAtUptimeNanoseconds
    }

    var dispatchTime: DispatchTime {
        absolute.dispatchTime
    }

    func authorizesNewWork(
        observedAtUptimeNanoseconds observed:
            UInt64,
        notBeforeUptimeNanoseconds prior:
            UInt64? = nil
    ) throws -> Bool {
        try absolute
            .isStrictlyBeforeExpiration(
                observed,
                notBefore: prior
            )
    }

    func acceptsCompletion(
        observedAtUptimeNanoseconds observed:
            UInt64,
        notBeforeUptimeNanoseconds prior:
            UInt64? = nil
    ) throws -> Bool {
        try absolute
            .isAtOrBeforeExpiration(
                observed,
                notBefore: prior
            )
    }
}

/// Bounded cleanup-only time authority.
///
/// A resumed child receives a TERM grace before KILL. A child rejected while
/// still suspended starts at KILL and therefore cannot accidentally consume
/// an unused TERM grace. This type intentionally exposes no phase-success
/// predicate.
struct PrimeSecureChildCleanupTimeline:
    Equatable,
    Sendable
{
    static let signalGraceNanoseconds:
        UInt64 = 2_000_000_000
    static let containmentGraceNanoseconds:
        UInt64 = 2_000_000_000
    static let drainGraceNanoseconds:
        UInt64 = 3_000_000_000

    let cleanupStartedAtUptimeNanoseconds:
        UInt64
    enum SignalPlan:
        Equatable,
        Sendable
    {
        case suspended(
            killDeadline:
                PrimeSecureChildAbsoluteDeadline
        )
        case resumed(
            terminationDeadline:
                PrimeSecureChildAbsoluteDeadline,
            killDeadline:
                PrimeSecureChildAbsoluteDeadline
        )
    }

    let signalPlan: SignalPlan
    let killDeadline:
        PrimeSecureChildAbsoluteDeadline
    let containmentDeadline:
        PrimeSecureChildAbsoluteDeadline
    let drainDeadline:
        PrimeSecureChildAbsoluteDeadline

    static func resumed(
        cleanupStartedAtUptimeNanoseconds start:
            UInt64
    ) throws -> Self {
        let termination =
            try PrimeSecureChildAbsoluteDeadline(
                startUptimeNanoseconds: start,
                durationNanoseconds:
                    signalGraceNanoseconds
            )
        return try make(
            cleanupStartedAtUptimeNanoseconds:
                start,
            terminationDeadline: termination,
            killStartedAtUptimeNanoseconds:
                termination
                .expiresAtUptimeNanoseconds
        )
    }

    static func suspended(
        cleanupStartedAtUptimeNanoseconds start:
            UInt64
    ) throws -> Self {
        try make(
            cleanupStartedAtUptimeNanoseconds:
                start,
            terminationDeadline: nil,
            killStartedAtUptimeNanoseconds:
                start
        )
    }

    func requireNonregressingObservation(
        _ observedUptimeNanoseconds: UInt64,
        notBefore priorUptimeNanoseconds:
            UInt64? = nil
    ) throws {
        let lowerBound =
            priorUptimeNanoseconds
            ?? cleanupStartedAtUptimeNanoseconds
        guard lowerBound
                >= cleanupStartedAtUptimeNanoseconds,
              observedUptimeNanoseconds
                >= lowerBound
        else {
            throw PrimeSecureChildDeadlineError
                .clockRegression(
                    observedUptimeNanoseconds:
                        observedUptimeNanoseconds,
                    notBeforeUptimeNanoseconds:
                        max(
                            lowerBound,
                            cleanupStartedAtUptimeNanoseconds
                        )
                )
        }
    }

    private static func make(
        cleanupStartedAtUptimeNanoseconds start:
            UInt64,
        terminationDeadline:
            PrimeSecureChildAbsoluteDeadline?,
        killStartedAtUptimeNanoseconds killStart:
            UInt64
    ) throws -> Self {
        let kill =
            try PrimeSecureChildAbsoluteDeadline(
                startUptimeNanoseconds:
                    killStart,
                durationNanoseconds:
                    signalGraceNanoseconds
            )
        let containment =
            try PrimeSecureChildAbsoluteDeadline(
                startUptimeNanoseconds:
                    kill
                    .expiresAtUptimeNanoseconds,
                durationNanoseconds:
                    containmentGraceNanoseconds
            )
        let drain =
            try PrimeSecureChildAbsoluteDeadline(
                startUptimeNanoseconds:
                    containment
                    .expiresAtUptimeNanoseconds,
                durationNanoseconds:
                    drainGraceNanoseconds
            )
        let signalPlan: SignalPlan
        if let terminationDeadline {
            signalPlan = .resumed(
                terminationDeadline:
                    terminationDeadline,
                killDeadline: kill
            )
        } else {
            signalPlan = .suspended(
                killDeadline: kill
            )
        }
        return Self(
            cleanupStartedAtUptimeNanoseconds:
                start,
            signalPlan: signalPlan,
            killDeadline: kill,
            containmentDeadline:
                containment,
            drainDeadline: drain
        )
    }
}
