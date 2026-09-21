public enum PrimeWorkerCandidateKind:
    String,
    Codable,
    Sendable
{
    case grounded
    case abstain
    case missing
    case invalid
}

public enum PrimeWorkerTerminationKind:
    String,
    Codable,
    Sendable
{
    case exit
    case uncaughtSignal = "uncaught_signal"
    case unknown
}

public struct PrimeSupervisorObservation:
    Equatable,
    Sendable
{
    public let terminationObserved: Bool
    public let hardTimeoutObserved: Bool
    public let terminationKind:
        PrimeWorkerTerminationKind
    public let terminationStatus: Int32
    public let candidate: PrimeWorkerCandidateKind

    public init(
        terminationObserved: Bool,
        hardTimeoutObserved: Bool,
        terminationKind:
            PrimeWorkerTerminationKind,
        terminationStatus: Int32,
        candidate: PrimeWorkerCandidateKind
    ) {
        self.terminationObserved = terminationObserved
        self.hardTimeoutObserved =
            hardTimeoutObserved
        self.terminationKind = terminationKind
        self.terminationStatus = terminationStatus
        self.candidate = candidate
    }
}

public enum PrimeSupervisorDisposition:
    String,
    Equatable,
    Sendable
{
    case promoteGrounded =
        "promote_grounded"
    case publishTimeLimitAbstain =
        "publish_time_limit_abstain"
    case publishWorkerAbstain =
        "publish_worker_abstain"
    case publishContractAbstain =
        "publish_contract_abstain"
    case publishExecutorAbstain =
        "publish_executor_abstain"
    case withholdFinalReceipt =
        "withhold_final_receipt"
}

/// Pure adjudication for the process boundary. The supervisor performs no
/// receipt publication until this policy has observed the worker's terminal
/// state. A hard timeout always dominates a racing candidate, and a grounded
/// candidate is promotable only after a normal zero-status exit.
public enum PrimeSupervisorPolicy {
    public static func disposition(
        for observation: PrimeSupervisorObservation
    ) -> PrimeSupervisorDisposition {
        guard observation.terminationObserved else {
            return .withholdFinalReceipt
        }
        if observation.hardTimeoutObserved {
            return .publishTimeLimitAbstain
        }
        switch observation.candidate {
        case .grounded:
            guard observation.terminationKind == .exit,
                  observation.terminationStatus == 0 else {
                return .publishExecutorAbstain
            }
            return .promoteGrounded
        case .abstain:
            return .publishWorkerAbstain
        case .invalid:
            return .publishContractAbstain
        case .missing:
            return .publishExecutorAbstain
        }
    }
}
