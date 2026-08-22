// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin

/// Closed V2-SPAWN-01 child. The supervisor supplies no semantic input, and
/// this process deliberately performs no I/O or child creation.
@main
struct PrimeValidationWorkflowDriverV2SpawnCanary {
    static func main() {
        Darwin._exit(0)
    }
}
