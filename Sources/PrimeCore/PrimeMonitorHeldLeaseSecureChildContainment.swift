// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

/// Closed validation-fixture capability whose monitor retains one private
/// resource lease throughout the existing secure-child containment path.
///
/// The trusted directory is not a caller-selected resource identifier. This
/// capability derives its fixed lease leaf internally, acquires exactly once,
/// and exposes neither the lease nor a release handle. The existing secure
/// child supervisor remains the sole owner of child-process lifecycle.
public final class PrimeMonitorHeldLeaseSecureChildContainment:
    @unchecked Sendable
{
    private static let resourceLeaseLeaf =
        "prime-secure-child-monitor-held-resource-lease-v1.lock"

    private let prepared: PrimeSecureChildPreparedFixture
    private let capture: PrimeTrustedSecureChildProcessCapture

    private init(
        prepared: PrimeSecureChildPreparedFixture,
        capture: PrimeTrustedSecureChildProcessCapture
    ) {
        self.prepared = prepared
        self.capture = capture
    }

    @available(macOS 26.0, *)
    public static func prepare(
        trustedLeaseDirectoryURL: URL,
        executableURL: URL,
        privateWorkingDirectoryURL: URL,
        privateResultDirectoryURL: URL,
        mode: PrimeValidationWorkflowFixtureChildMode
    ) throws -> Self {
        let leaseURL = trustedLeaseDirectoryURL.appendingPathComponent(
            resourceLeaseLeaf,
            isDirectory: false
        )
        let lease = try PrimeExclusiveResourceLease.acquire(
            at: leaseURL
        )
        let plan = try PrimeSecureChildProcessPlanV1
            .validationWorkflowFixture(mode: mode)
        let prepared = try PrimeSecureChildPreparedFixture(
            executableURL: executableURL,
            workingDirectoryURL: privateWorkingDirectoryURL,
            resultDirectoryURL: privateResultDirectoryURL,
            plan: plan
        )
        let capture = captureRetaining(
            lease,
            plan: plan,
            closedContext: prepared
        )
        return Self(
            prepared: prepared,
            capture: capture
        )
    }

    @available(macOS 26.0, *)
    public func execute() throws
        -> PrimeValidationWorkflowFixtureChildResult
    {
        let consumption:
            PrimeTrustedSecureChildProcessCapture.Consumption
        do {
            consumption = try capture.consume()
        } catch {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("capability_already_consumed")
        }
        let execution = try PrimeSecureChildExecutionKernel.execute(
            consumption: consumption,
            prepared: prepared
        )
        guard let fixtureResult = execution.fixtureResult else {
            throw PrimeValidationWorkflowFixtureChildError.rejected(
                execution.operationalFailureCode
                    ?? "execution_kernel_result"
            )
        }
        return fixtureResult
    }

    /// Same-module seam for the sole pure in-memory topology test. Production
    /// supplies only the privately acquired lease above; the public capability
    /// accepts no lease object or caller-selected resource identifier.
    static func captureRetaining(
        _ lease: any PrimeExclusiveResourceLeaseCapability,
        plan: PrimeSecureChildProcessPlanV1,
        closedContext: AnyObject
    ) -> PrimeTrustedSecureChildProcessCapture {
        let exclusiveRetention =
            PrimeExclusiveResourceLeaseRetention(lease)
        let secureChildRetention = PrimeSecureChildLeaseRetention(
            externallyOwnedCapability: exclusiveRetention
        )
        return PrimeTrustedSecureChildProcessCapture(
            plan: plan,
            closedContext: closedContext,
            leaseRetention: secureChildRetention
        )
    }
}
