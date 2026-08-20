// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import XCTest
@testable import PrimeCore

private final class InMemoryMonitorHeldLeaseCapability:
    PrimeExclusiveResourceLeaseCapability
{}

private final class InMemorySecureChildClosedContext: @unchecked Sendable {}

private final class InMemoryWeakReference<Value: AnyObject> {
    weak var value: Value?

    init(_ value: Value?) {
        self.value = value
    }
}

final class PrimeMonitorHeldLeaseSecureChildContainmentTests:
    XCTestCase
{
    @available(macOS 26.0, *)
    func testPureInMemoryFakeRetainsOrderedOwnershipTopologyWithoutMechanics()
        throws
    {
        let prepare:
            (
                URL,
                URL,
                URL,
                URL,
                PrimeValidationWorkflowFixtureChildMode
            ) throws -> PrimeMonitorHeldLeaseSecureChildContainment =
                PrimeMonitorHeldLeaseSecureChildContainment.prepare
        let execute:
            (PrimeMonitorHeldLeaseSecureChildContainment)
                -> () throws
                -> PrimeValidationWorkflowFixtureChildResult =
                    PrimeMonitorHeldLeaseSecureChildContainment.execute
        _ = prepare
        _ = execute

        var lease: InMemoryMonitorHeldLeaseCapability? = .init()
        let weakLease = InMemoryWeakReference(lease)
        var closedContext: InMemorySecureChildClosedContext? = .init()
        let weakClosedContext = InMemoryWeakReference(closedContext)
        let plan = try PrimeSecureChildProcessPlanV1
            .validationWorkflowFixture(mode: .pass)

        var capture: PrimeTrustedSecureChildProcessCapture? =
            PrimeMonitorHeldLeaseSecureChildContainment.captureRetaining(
                lease!,
                plan: plan,
                closedContext: closedContext!
        )
        lease = nil
        closedContext = nil
        XCTAssertNotNil(weakLease.value)
        XCTAssertNotNil(weakClosedContext.value)

        var consumption:
            PrimeTrustedSecureChildProcessCapture.Consumption? =
                try capture!.consume()
        XCTAssertThrowsError(try capture!.consume()) {
            XCTAssertEqual(
                $0 as? PrimeTrustedSecureChildProcessCapture
                    .ConsumptionError,
                .alreadyConsumed
            )
        }
        capture = nil
        XCTAssertNotNil(weakLease.value)
        XCTAssertNotNil(weakClosedContext.value)

        var claim:
            PrimeTrustedSecureChildProcessCapture
            .Consumption.ExecutionClaim? =
                try consumption!.claimForExecution()
        XCTAssertThrowsError(try consumption!.claimForExecution()) {
            XCTAssertEqual(
                $0 as? PrimeTrustedSecureChildProcessCapture
                    .ConsumptionError,
                .alreadyClaimed
            )
        }
        consumption = nil
        XCTAssertNotNil(weakLease.value)
        XCTAssertNotNil(weakClosedContext.value)
        XCTAssertTrue(claim!.plan === plan)
        XCTAssertTrue(
            claim!.retainsClosedContext(weakClosedContext.value!)
        )
        do {
            let layerARetention = try XCTUnwrap(claim!.leaseRetention)
            XCTAssertFalse(
                layerARetention.retainsExternallyOwnedCapability(
                    weakLease.value!
                )
            )
            let telemetry = layerARetention.telemetry
            XCTAssertEqual(telemetry.scope, .cooperatingHostPathLocal)
            XCTAssertTrue(telemetry.advisory)
            XCTAssertTrue(telemetry.ownerMustRemainLive)
            XCTAssertFalse(telemetry.childLifetimeContinuityEstablished)
            XCTAssertFalse(telemetry.mlxDeviceIdentityEstablished)
            XCTAssertFalse(telemetry.durableEvidenceEstablished)
        }

        claim = nil
        XCTAssertNil(weakLease.value)
        XCTAssertNil(weakClosedContext.value)
    }
}
