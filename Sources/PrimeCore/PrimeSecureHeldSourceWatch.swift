// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin

/// Domain-neutral live wrapper over Prime's maintained descriptor and kqueue
/// source-closure mechanics.
///
/// The underlying implementation predates the validation executor and keeps
/// its historical type name for source compatibility. This wrapper prevents
/// the new validation boundary from duplicating that security-sensitive
/// implementation or treating a neural-gate receipt as its authority.
final class PrimeSecureHeldSourceWatch {
    private let implementation:
        PrimeNativeNeuralGateHeldSourceClosure

    init(
        rootDescriptor: Int32,
        sourceSnapshot: PrimeSwiftSourceSnapshot
    ) throws {
        implementation = try
            PrimeNativeNeuralGateHeldSourceClosure(
                rootDescriptor: rootDescriptor,
                sourceSnapshot: sourceSnapshot
            )
    }

    func revalidateWhilePrepared() throws -> UInt64 {
        try implementation.validateWhilePrepared()
    }
}
