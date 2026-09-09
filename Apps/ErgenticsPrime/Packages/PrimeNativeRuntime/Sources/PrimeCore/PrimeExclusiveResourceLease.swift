// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public typealias PrimeExclusiveResourceLease = PrimeMetalDeviceLease
public typealias PrimeExclusiveResourceLeaseError = PrimeMetalDeviceLeaseError

protocol PrimeExclusiveResourceLeaseCapability: AnyObject, Sendable {}

extension PrimeMetalDeviceLease: PrimeExclusiveResourceLeaseCapability {}

final class PrimeExclusiveResourceLeaseRetention: Sendable
{
    private let lease: any PrimeExclusiveResourceLeaseCapability

    init(_ lease: any PrimeExclusiveResourceLeaseCapability)
    {
        self.lease = lease
    }

    func retains(_ candidate: any PrimeExclusiveResourceLeaseCapability) -> Bool
    {
        ObjectIdentifier(lease) == ObjectIdentifier(candidate)
    }
}
