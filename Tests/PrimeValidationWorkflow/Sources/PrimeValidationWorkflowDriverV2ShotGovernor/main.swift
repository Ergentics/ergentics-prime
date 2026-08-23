// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import PrimeValidationWorkflowDriverV2ShotGovernorCore

/// The production governor is deliberately silent. The only transport is the
/// one canonical capsule on standard input; the core returns one frozen status
/// and this target adds no command, path, role, or environment surface.
@main
private struct PrimeValidationWorkflowDriverV2ShotGovernorMain {
    static func main() {
        Darwin._exit(
            PrimeValidationDriverV2ShotGovernor.runClosedFromStandardInput()
        )
    }
}
