// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import PrimeNativeNeuralGateHistoricalEvidenceExportMechanics
import PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection

/// A compiler-checked but lexically unreachable carrier-to-projector edge.
///
/// `PrimeNativeNeuralGateHistoricalFixtureWorker.main` remains in a separate
/// source file and exits unavailable. This private member cannot be named from
/// that file. It does not construct context, execute the exporter, integrate
/// transport, write artifacts, or publish evidence.
extension PrimeNativeNeuralGateHistoricalFixtureWorker {
    private static func
        sourceBoundHistoricalEvidenceSemanticArtifactProjectionCallEdge(
            evidence:
                PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,
            context:
                PrimeNativeNeuralGateHistoricalProjectionContext
        ) throws
        -> PrimeNativeNeuralGateHistoricalProjectedArtifactSet
    {
        try PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection
            .project(
                evidence: evidence,
                context: context
            )
    }
}
