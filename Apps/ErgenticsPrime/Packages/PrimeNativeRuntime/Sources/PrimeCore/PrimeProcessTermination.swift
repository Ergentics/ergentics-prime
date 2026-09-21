import Darwin

public struct PrimeSignalDelivery:
    Equatable,
    Sendable
{
    public let signal: Int32
    public let result: Int32
    public let errorNumber: Int32

    public init(
        signal: Int32,
        result: Int32,
        errorNumber: Int32
    ) {
        self.signal = signal
        self.result = result
        self.errorNumber = errorNumber
    }
}

public enum PrimeTerminationEscalationOutcome:
    Equatable,
    Sendable
{
    case observedAfterSIGTERM(
        term: PrimeSignalDelivery
    )
    case observedAfterSIGKILL(
        term: PrimeSignalDelivery,
        kill: PrimeSignalDelivery
    )
    case unobservedAfterSIGKILL(
        term: PrimeSignalDelivery,
        kill: PrimeSignalDelivery
    )

    public var terminationObserved: Bool {
        switch self {
        case .observedAfterSIGTERM,
             .observedAfterSIGKILL:
            true
        case .unobservedAfterSIGKILL:
            false
        }
    }

    public var auditDetail: String {
        switch self {
        case let .observedAfterSIGTERM(term):
            signalDetail(label: "SIGTERM", delivery: term)
        case let .observedAfterSIGKILL(term, kill),
             let .unobservedAfterSIGKILL(term, kill):
            signalDetail(label: "SIGTERM", delivery: term)
                + "; "
                + signalDetail(label: "SIGKILL", delivery: kill)
        }
    }

    private func signalDetail(
        label: String,
        delivery: PrimeSignalDelivery
    ) -> String {
        "\(label) result=\(delivery.result) errno=\(delivery.errorNumber)"
    }
}

/// Performs the supervisor's bounded post-timeout signal escalation.
///
/// A caller supplies the bounded wait because the executable owns the
/// termination semaphore. The injectable signal delivery is retained so the
/// exact SIGTERM -> grace -> SIGKILL -> grace sequence can be tested without
/// launching an untrusted helper process.
public enum PrimeProcessTermination {
    public static func escalateAfterTimeout(
        processIdentifier: Int32,
        graceMilliseconds: Int,
        waitForTermination: (Int) -> Bool
    ) -> PrimeTerminationEscalationOutcome {
        escalateAfterTimeout(
            processIdentifier: processIdentifier,
            graceMilliseconds: graceMilliseconds,
            waitForTermination: waitForTermination,
            sendSignal: deliverSignal
        )
    }

    public static func escalateAfterTimeout(
        processIdentifier: Int32,
        graceMilliseconds: Int,
        waitForTermination: (Int) -> Bool,
        sendSignal:
            (Int32, Int32) -> PrimeSignalDelivery
    ) -> PrimeTerminationEscalationOutcome {
        let term = sendSignal(
            processIdentifier,
            SIGTERM
        )
        if waitForTermination(graceMilliseconds) {
            return .observedAfterSIGTERM(term: term)
        }

        let kill = sendSignal(
            processIdentifier,
            SIGKILL
        )
        if waitForTermination(graceMilliseconds) {
            return .observedAfterSIGKILL(
                term: term,
                kill: kill
            )
        }
        return .unobservedAfterSIGKILL(
            term: term,
            kill: kill
        )
    }

    private static func deliverSignal(
        processIdentifier: Int32,
        signal: Int32
    ) -> PrimeSignalDelivery {
        errno = 0
        let result = Darwin.kill(
            processIdentifier,
            signal
        )
        return PrimeSignalDelivery(
            signal: signal,
            result: result,
            errorNumber: errno
        )
    }
}
