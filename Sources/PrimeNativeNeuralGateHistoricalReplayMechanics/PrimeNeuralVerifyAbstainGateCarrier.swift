import Foundation

/// **VerifyAbstainGate-shaped** dispose for Core ML math / deep cannons (≥3 independent witnesses).
/// See `docs/ABSTAIN-VOCAB.md` · `PMHNPTriadVerifyGate` · ergentics-logic `SEAL-GATE-ARCHITECTURE.md`.
public enum PrimeNeuralVerifyAbstainGate {

    public static let minIndependentWitnesses = 3

    public struct Witness: Sendable, Equatable {
        public let leg: String
        public let pass: Bool
        public let detail: String
        public let independent: Bool

        public init(leg: String, pass: Bool, detail: String, independent: Bool = true) {
            self.leg = leg
            self.pass = pass
            self.detail = detail
            self.independent = independent
        }
    }

    public enum Outcome: String, Sendable {
        case grounded
        case verifyAbstain
    }

    public struct Verdict: Sendable, Equatable {
        public let witnesses: [Witness]
        public let outcome: Outcome
        public let agreeCount: Int

        public var grounded: Bool { outcome == .grounded }

        public init(witnesses: [Witness], outcome override: Outcome? = nil) {
            self.witnesses = witnesses
            self.agreeCount = witnesses.filter(\.pass).count
            if let override {
                self.outcome = override
            } else {
                self.outcome = agreeCount >= minIndependentWitnesses ? .grounded : .verifyAbstain
            }
        }

        public var legBreakdown: String {
            witnesses.map { "\($0.leg)=\($0.pass ? "pass" : "FAIL") (\($0.detail))" }.joined(separator: "; ")
        }

        /// Independent witnesses that pass (each leg is a distinct algorithm family in dispose).
        public var independentPassCount: Int {
            witnesses.filter { $0.independent && $0.pass }.count
        }

        /// SEAL-GATE shaped: `independentThreePlus(k)` when k ≥ min bar; else honest `oracleDerived(k)` hold.
        public var triadicVerdict: String {
            let k = independentPassCount
            if k >= minIndependentWitnesses {
                return "independentThreePlus(\(k))"
            }
            return "oracleDerived(\(k))"
        }

        /// **HELD=DERIVE** — abstain outcome is engine-derived, not asserted evidence (see `oracleDerived(2)` holds).
        public var heldDerive: Bool { outcome == .verifyAbstain }
    }
}
