// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

/// Opaque retention only. This seam cannot acquire, release, reacquire, or
/// prove ownership of a lease, and its telemetry is not durable evidence.
final class PrimeSecureChildLeaseRetention: @unchecked Sendable {
    struct Telemetry: Equatable, Sendable {
        enum Scope: String, Equatable, Sendable {
            case cooperatingHostPathLocal =
                "cooperating_host_path_local"
        }

        let scope: Scope
        let advisory: Bool
        let ownerMustRemainLive: Bool
        let childLifetimeContinuityEstablished: Bool
        let mlxDeviceIdentityEstablished: Bool
        let durableEvidenceEstablished: Bool

        private init(
            scope: Scope,
            advisory: Bool,
            ownerMustRemainLive: Bool,
            childLifetimeContinuityEstablished: Bool,
            mlxDeviceIdentityEstablished: Bool,
            durableEvidenceEstablished: Bool
        ) {
            self.scope = scope
            self.advisory = advisory
            self.ownerMustRemainLive = ownerMustRemainLive
            self.childLifetimeContinuityEstablished =
                childLifetimeContinuityEstablished
            self.mlxDeviceIdentityEstablished =
                mlxDeviceIdentityEstablished
            self.durableEvidenceEstablished =
                durableEvidenceEstablished
        }

        static let externallyOwnedAdvisory = Telemetry(
            scope: .cooperatingHostPathLocal,
            advisory: true,
            ownerMustRemainLive: true,
            childLifetimeContinuityEstablished: false,
            mlxDeviceIdentityEstablished: false,
            durableEvidenceEstablished: false
        )
    }

    let telemetry: Telemetry
    private let externallyOwnedCapability: AnyObject

    init(
        externallyOwnedCapability: AnyObject
    ) {
        self.externallyOwnedCapability = externallyOwnedCapability
        telemetry = .externallyOwnedAdvisory
    }

    func retainsExternallyOwnedCapability(_ candidate: AnyObject) -> Bool {
        ObjectIdentifier(externallyOwnedCapability)
            == ObjectIdentifier(candidate)
    }
}

/// Exactly-one-shot transfer of a closed plan and adapter-owned prepared
/// context. It exposes no process operation and no general execution inputs.
final class PrimeTrustedSecureChildProcessCapture: @unchecked Sendable {
    enum ConsumptionError: Error, Equatable, Sendable {
        case alreadyConsumed
        case alreadyClaimed
    }

    final class Consumption: @unchecked Sendable {
        final class ExecutionClaim: @unchecked Sendable {
            let plan: PrimeSecureChildProcessPlanV1
            let leaseRetention: PrimeSecureChildLeaseRetention?
            private let closedContext: AnyObject

            fileprivate init(
                plan: PrimeSecureChildProcessPlanV1,
                closedContext: AnyObject,
                leaseRetention: PrimeSecureChildLeaseRetention?
            ) {
                self.plan = plan
                self.closedContext = closedContext
                self.leaseRetention = leaseRetention
            }

            func retainsClosedContext(_ candidate: AnyObject) -> Bool {
                ObjectIdentifier(closedContext)
                    == ObjectIdentifier(candidate)
            }
        }

        private struct ClaimState {
            let plan: PrimeSecureChildProcessPlanV1
            let closedContext: AnyObject
            let leaseRetention: PrimeSecureChildLeaseRetention?
        }

        private let lock = NSLock()
        private var claimState: ClaimState?

        fileprivate init(
            plan: PrimeSecureChildProcessPlanV1,
            closedContext: AnyObject,
            leaseRetention: PrimeSecureChildLeaseRetention?
        ) {
            claimState = ClaimState(
                plan: plan,
                closedContext: closedContext,
                leaseRetention: leaseRetention
            )
        }

        func claimForExecution() throws -> ExecutionClaim {
            lock.lock()
            defer { lock.unlock() }
            guard let claimState else {
                throw ConsumptionError.alreadyClaimed
            }
            self.claimState = nil
            return ExecutionClaim(
                plan: claimState.plan,
                closedContext: claimState.closedContext,
                leaseRetention: claimState.leaseRetention
            )
        }
    }

    private struct State {
        let plan: PrimeSecureChildProcessPlanV1
        let closedContext: AnyObject
        let leaseRetention: PrimeSecureChildLeaseRetention?
    }

    private let lock = NSLock()
    private var state: State?

    init(
        plan: PrimeSecureChildProcessPlanV1,
        closedContext: AnyObject,
        leaseRetention: PrimeSecureChildLeaseRetention? = nil
    ) {
        state = State(
            plan: plan,
            closedContext: closedContext,
            leaseRetention: leaseRetention
        )
    }

    func consume() throws -> Consumption {
        lock.lock()
        defer { lock.unlock() }
        guard let state else {
            throw ConsumptionError.alreadyConsumed
        }
        self.state = nil
        return Consumption(
            plan: state.plan,
            closedContext: state.closedContext,
            leaseRetention: state.leaseRetention
        )
    }
}
