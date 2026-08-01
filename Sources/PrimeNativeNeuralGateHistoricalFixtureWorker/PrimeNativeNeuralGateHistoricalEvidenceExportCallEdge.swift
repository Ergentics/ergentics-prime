// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeNativeNeuralGateHistoricalEvidenceExportMechanics
import PrimeNativeNeuralGateHistoricalReplayMechanics

/// A compiler-checked but lexically unreachable worker-to-exporter edge.
///
/// `PrimeNativeNeuralGateHistoricalFixtureWorker.main` remains in a separate
/// source file and exits unavailable. This private member cannot be named from
/// that file. It does not seal, launch, execute, encode, or publish evidence.
extension PrimeNativeNeuralGateHistoricalFixtureWorker {
    private static func sourceBoundHistoricalEvidenceExportCallEdge()
        throws
        -> PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence
    {
        guard let packageResolvedURL = Bundle.module.url(
            forResource: "Package",
            withExtension: "resolved",
            subdirectory: "HistoricalFixtureEvidence"
        ) else {
            throw HistoricalEvidenceExportCallEdgeError
                .missingPinnedPackageResolved
        }
        let fixture = try
            EngineProposesNativeLanguageVerifyAbstainFixture
            .materialize(
                packageResolvedURL: packageResolvedURL
            )
        return try PrimeNativeNeuralGateHistoricalEvidenceExporter
            .export(fixture.materials)
    }

    private enum HistoricalEvidenceExportCallEdgeError:
        Error
    {
        case missingPinnedPackageResolved
    }
}
