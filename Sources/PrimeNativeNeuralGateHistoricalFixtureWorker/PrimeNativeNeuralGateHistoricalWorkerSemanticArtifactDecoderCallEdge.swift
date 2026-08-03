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

import PrimeNativeNeuralGateHistoricalEvidenceExportMechanics

private enum
    PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionError:
    Error,
    Equatable,
    Sendable
{
    case contextMustRemainUnavailable
    case invalidArtifactLinkage
}

private struct
    PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult:
    Sendable
{
    let projectedArtifacts:
        PrimeNativeNeuralGateHistoricalProjectedArtifactSet
    let decodedArtifacts:
        PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet
}

/// A compiler-checked but lexically unreachable exported-evidence composition.
///
/// The exact V19 decoder edge above remains the byte-for-byte source prefix.
/// This continuation accepts only an already-formed evidence carrier and an
/// explicit unavailable-only projection context, then reuses the maintained
/// projector and private decoder edge. No runtime-reachable entry point or
/// invocation wiring is added; the composition itself performs no I/O,
/// transport, publication, receipt, source-binding, or authority action.
extension PrimeNativeNeuralGateHistoricalFixtureWorker {
    private static func compose(
        evidence:
            PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,
        context:
            PrimeNativeNeuralGateHistoricalProjectionContext
    ) throws
        -> PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult
    {
        guard context.sourceBytesResolved == .unavailable,
              context.adaptationProofRecomputed == .unavailable
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionError
                .contextMustRemainUnavailable
        }

        let projectedArtifacts = try
            PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection
            .project(
                evidence: evidence,
                context: context
            )
        let decodedArtifacts = try
            sourceBoundHistoricalSemanticArtifactDecoderCallEdge(
                projectedArtifacts: projectedArtifacts
            )

        let orderedBindings =
            decodedArtifacts.orderedArtifactBindings
        let projectedSpecifications =
            projectedArtifacts.orderedArtifacts.map(\.specification)
        let decodedSpecifications = try orderedBindings.map {
            try $0.specification
        }
        guard projectedArtifacts.invocationRole
                == context.invocationRole,
              projectedArtifacts.invocationRole
                == decodedArtifacts.canonicalLeaves.invocationRole,
              projectedArtifacts.orderedArtifacts.count == 22,
              orderedBindings.count == 22,
              Set(orderedBindings.map(\.key)).count == 22,
              projectedSpecifications == decodedSpecifications
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionError
                .invalidArtifactLinkage
        }

        for binding in orderedBindings {
            let projectedArtifact = try projectedArtifacts.artifact(
                for: binding.key
            )
            guard projectedArtifact.specification
                    == (try binding.specification),
                  projectedArtifact.byteCount == binding.byteCount,
                  projectedArtifact.sha256 == binding.sha256
            else {
                throw PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionError
                    .invalidArtifactLinkage
            }
        }

        return
            PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult(
                projectedArtifacts: projectedArtifacts,
                decodedArtifacts: decodedArtifacts
            )
    }

    private static func
        sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge(
            evidence:
                PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,
            context:
                PrimeNativeNeuralGateHistoricalProjectionContext
        ) throws
        -> PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult
    {
        try compose(
            evidence: evidence,
            context: context
        )
    }
}

/// A compiler-bound, nonpublic access seam around the V21 composition edge.
///
/// This wrapper intentionally exposes no declared payload accessor. Swift
/// private storage is API hiding rather than a confidentiality boundary, so a
/// later caller still requires a separate reflection/leakage review. The value
/// remains ordinarily copyable and Swift may infer `Sendable` from its payload;
/// neither property creates a confidentiality or concurrency-security boundary.
/// No checked-in caller, `main` call path, request/transport path, or observed
/// invocation is added; no execution, I/O, publication, receipt, source-binding
/// V7, or authority action is observed or authorized here.
extension PrimeNativeNeuralGateHistoricalFixtureWorker {
    internal struct
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult
    {
        private let compositionResult:
            PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult

        private init(
            compositionResult:
                PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult
        ) {
            self.compositionResult = compositionResult
        }

        private static func
            sourceBoundUnavailableHistoricalWorkerInvocationSeam(
                evidence:
                    PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,
                context:
                    PrimeNativeNeuralGateHistoricalProjectionContext
            ) throws -> Self
        {
            Self(
                compositionResult: try
                    PrimeNativeNeuralGateHistoricalFixtureWorker
                    .sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge(
                        evidence: evidence,
                        context: context
                    )
            )
        }
    }
}

extension PrimeNativeNeuralGateHistoricalFixtureWorker
    .PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult
{
    internal enum CallerResultConsumerDisposition {
        case compositionCompletedAndDiscarded
        case failedClosedWithoutDetail
    }

    internal static func
        sourceBoundUnavailableHistoricalWorkerInvocationSeamCallerAndDiscardConsumer(
            evidence:
                PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,
            context:
                PrimeNativeNeuralGateHistoricalProjectionContext
        ) -> CallerResultConsumerDisposition
    {
        do {
            _ = try Self
                .sourceBoundUnavailableHistoricalWorkerInvocationSeam(
                    evidence: evidence,
                    context: context
                )
            return .compositionCompletedAndDiscarded
        } catch {
            return .failedClosedWithoutDetail
        }
    }
}
