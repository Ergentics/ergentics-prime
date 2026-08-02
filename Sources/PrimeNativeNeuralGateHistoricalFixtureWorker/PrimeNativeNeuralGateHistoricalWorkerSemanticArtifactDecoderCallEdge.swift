// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection
import PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder

/// A compiler-checked but lexically unreachable projected-set-to-decoder edge.
///
/// `PrimeNativeNeuralGateHistoricalFixtureWorker.main` remains in a separate
/// source file and exits unavailable. This private member cannot be named from
/// that file. It accepts only an already-formed V16 projected artifact set and
/// delegates semantic validation to the maintained V18 decoder. It performs no
/// I/O, transport, execution, publication, receipt, or source-binding action.
extension PrimeNativeNeuralGateHistoricalFixtureWorker {
    private static func
        sourceBoundHistoricalSemanticArtifactDecoderCallEdge(
            projectedArtifacts:
                PrimeNativeNeuralGateHistoricalProjectedArtifactSet
        ) throws
        -> PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet
    {
        try projectedArtifacts.validate()
        let role = projectedArtifacts.invocationRole
        let canonicalArtifacts = try [
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput(
                key: .materialIdentityManifest(role),
                bytes: projectedArtifacts.artifact(
                    for: .materialIdentityManifest(role)
                ).bytes
            ),
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput(
                key: .gateObservation(role),
                bytes: projectedArtifacts.artifact(
                    for: .gateObservation(role)
                ).bytes
            ),
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput(
                key: .invariantRecordsManifest(role),
                bytes: projectedArtifacts.artifact(
                    for: .invariantRecordsManifest(role)
                ).bytes
            ),
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput(
                key: .fingerprintObservation(role),
                bytes: projectedArtifacts.artifact(
                    for: .fingerprintObservation(role)
                ).bytes
            ),
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput(
                key: .mutationObservations(role),
                bytes: projectedArtifacts.artifact(
                    for: .mutationObservations(role)
                ).bytes
            ),
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput(
                key: .statisticsVerdictObservation(role),
                bytes: projectedArtifacts.artifact(
                    for: .statisticsVerdictObservation(role)
                ).bytes
            ),
        ]
        let decodedLeaves = try
            PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder
            .decodeCanonicalLeaves(
                invocationRole: role,
                artifacts: canonicalArtifacts
            )
        let streamDecoder = try
            PrimeNativeNeuralGateHistoricalInvariantArtifactStreamDecoder(
                decodedLeaves: decodedLeaves
            )
        let globalBytes = try projectedArtifacts.artifact(
            for: .invariantRecordsGlobal(role)
        ).bytes
        var globalOffset = globalBytes.startIndex
        let maximumFeedByteCount =
            PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder
            .descriptorFeedMaximumByteCount

        for ordinal in decodedLeaves.invariantManifest
            .manifest.chunks.indices
        {
            let chunkBytes = try projectedArtifacts.artifact(
                for: .invariantChunk(role, UInt32(ordinal))
            ).bytes
            var chunkOffset = chunkBytes.startIndex

            while globalOffset < globalBytes.endIndex,
                  chunkOffset < chunkBytes.endIndex
            {
                let pairedRemainingByteCount = min(
                    globalBytes.distance(
                        from: globalOffset,
                        to: globalBytes.endIndex
                    ),
                    chunkBytes.distance(
                        from: chunkOffset,
                        to: chunkBytes.endIndex
                    )
                )
                let feedByteCount = min(
                    maximumFeedByteCount,
                    pairedRemainingByteCount
                )
                let globalEnd = globalBytes.index(
                    globalOffset,
                    offsetBy: feedByteCount
                )
                try streamDecoder.consume(
                    PrimeNativeNeuralGateHistoricalSemanticArtifactInput(
                        key: .invariantRecordsGlobal(role),
                        bytes: globalBytes[globalOffset ..< globalEnd]
                    )
                )
                globalOffset = globalEnd

                let chunkEnd = chunkBytes.index(
                    chunkOffset,
                    offsetBy: feedByteCount
                )
                try streamDecoder.consume(
                    PrimeNativeNeuralGateHistoricalSemanticArtifactInput(
                        key: .invariantChunk(role, UInt32(ordinal)),
                        bytes: chunkBytes[chunkOffset ..< chunkEnd]
                    )
                )
                chunkOffset = chunkEnd
            }

            while chunkOffset < chunkBytes.endIndex {
                let chunkEnd = chunkBytes.index(
                    chunkOffset,
                    offsetBy: min(
                        maximumFeedByteCount,
                        chunkBytes.distance(
                            from: chunkOffset,
                            to: chunkBytes.endIndex
                        )
                    )
                )
                try streamDecoder.consume(
                    PrimeNativeNeuralGateHistoricalSemanticArtifactInput(
                        key: .invariantChunk(role, UInt32(ordinal)),
                        bytes: chunkBytes[chunkOffset ..< chunkEnd]
                    )
                )
                chunkOffset = chunkEnd
            }
            try streamDecoder.finishCurrentChunk()
        }

        while globalOffset < globalBytes.endIndex {
            let globalEnd = globalBytes.index(
                globalOffset,
                offsetBy: min(
                    maximumFeedByteCount,
                    globalBytes.distance(
                        from: globalOffset,
                        to: globalBytes.endIndex
                    )
                )
            )
            try streamDecoder.consume(
                PrimeNativeNeuralGateHistoricalSemanticArtifactInput(
                    key: .invariantRecordsGlobal(role),
                    bytes: globalBytes[globalOffset ..< globalEnd]
                )
            )
            globalOffset = globalEnd
        }

        return try streamDecoder.finishSemanticArtifactSet()
    }
}
