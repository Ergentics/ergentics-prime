// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import PrimeValidationWorkflowDriverV2ShotGovernorCore

/// Success is silent. Transport/admission failures may emit one bounded
/// diagnostic when stderr cannot block on a pipe. The only input transport is
/// one canonical capsule on stdin; the core returns one frozen status and this
/// target adds no command, path, role, or environment surface.
@main
private struct PrimeValidationWorkflowDriverV2ShotGovernorMain {
    static func main() {
        Darwin._exit(
            PrimeValidationDriverV2ShotGovernor.runClosedFromStandardInput()
        )
    }
}
