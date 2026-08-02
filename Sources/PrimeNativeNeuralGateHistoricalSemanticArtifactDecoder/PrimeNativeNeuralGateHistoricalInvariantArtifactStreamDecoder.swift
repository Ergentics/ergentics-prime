// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateSemanticRecordContracts

public struct PrimeNativeNeuralGateHistoricalDecodedInvariantStreams:
    Equatable,
    Sendable
{
    public let global:
        PrimeNativeNeuralGateInvariantFramedStreamSummary
    public let orderedChunks:
        [PrimeNativeNeuralGateInvariantFramedStreamSummary]
    public let matchedRecordCount: Int
    public let streamArtifactBindings:
        [PrimeNativeNeuralGateHistoricalSemanticArtifactBinding]

    init(
        global:
            PrimeNativeNeuralGateInvariantFramedStreamSummary,
        orderedChunks:
            [PrimeNativeNeuralGateInvariantFramedStreamSummary],
        matchedRecordCount: Int,
        streamArtifactBindings:
            [PrimeNativeNeuralGateHistoricalSemanticArtifactBinding]
    ) {
        self.global = global
        self.orderedChunks = orderedChunks
        self.matchedRecordCount = matchedRecordCount
        self.streamArtifactBindings = streamArtifactBindings
    }

    public func binding(
        for key:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
    ) throws
        -> PrimeNativeNeuralGateHistoricalSemanticArtifactBinding
    {
        guard let value = streamArtifactBindings.first(
            where: { $0.key == key }
        ) else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .missingArtifactKey("stream_artifact")
        }
        return value
    }
}

public struct PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet:
    Equatable,
    Sendable
{
    public let canonicalLeaves:
        PrimeNativeNeuralGateHistoricalDecodedCanonicalLeaves
    public let invariantStreams:
        PrimeNativeNeuralGateHistoricalDecodedInvariantStreams
    public let orderedArtifactBindings:
        [PrimeNativeNeuralGateHistoricalSemanticArtifactBinding]
    public let artifactWritePerformed: Bool
    public let evidencePublished: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    init(
        canonicalLeaves:
            PrimeNativeNeuralGateHistoricalDecodedCanonicalLeaves,
        invariantStreams:
            PrimeNativeNeuralGateHistoricalDecodedInvariantStreams
    ) throws {
        self.canonicalLeaves = canonicalLeaves
        self.invariantStreams = invariantStreams
        let role = canonicalLeaves.invocationRole
        orderedArtifactBindings = try
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .allKeys(for: role).map { key in
                switch key {
                case .materialIdentityManifest,
                     .gateObservation,
                     .invariantRecordsManifest,
                     .fingerprintObservation,
                     .mutationObservations,
                     .statisticsVerdictObservation:
                    return try canonicalLeaves.binding(for: key)
                case .invariantRecordsGlobal,
                     .invariantChunk:
                    return try invariantStreams.binding(for: key)
                }
            }
        guard orderedArtifactBindings.count == 22,
              Set(orderedArtifactBindings.map(\.key)).count == 22
        else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidArtifactSet("complete_binding_coverage")
        }
        artifactWritePerformed = false
        evidencePublished = false
        mechanicsPassAuthorized = false
        terminalReceiptAuthorized = false
        sourceBindingV7Issued = false
        scientificAuthorityAuthorized = false
        productAuthorityAuthorized = false
    }
}

/// Bounded, caller-fed equality decoder for the global PRIMEIRM1 stream and
/// the ordered PRIMEIRC1 partitions. It owns no descriptor or I/O operation.
public final class
    PrimeNativeNeuralGateHistoricalInvariantArtifactStreamDecoder
{
    private enum State {
        case active
        case finished(
            PrimeNativeNeuralGateHistoricalDecodedInvariantStreams
        )
        case poisoned
    }

    private static let maximumPendingRecordCount = 8_194
    private static let maximumPendingRecordBytes =
        PrimeNativeNeuralGateReplayDecodeLimits
        .stageB.maximumRecordByteCount
        + 2
            * PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder
            .descriptorFeedMaximumByteCount

    private let decodedLeaves:
        PrimeNativeNeuralGateHistoricalDecodedCanonicalLeaves
    private let globalReader:
        PrimeNativeNeuralGateInvariantFramedRecordReader
    private var currentChunkReader:
        PrimeNativeNeuralGateInvariantFramedRecordReader?
    private var state = State.active
    private var nextChunkOrdinal: UInt32 = 0
    private var globalInputByteCount: UInt64 = 0
    private var currentChunkInputByteCount: UInt64 = 0
    private var globalSummary:
        PrimeNativeNeuralGateInvariantFramedStreamSummary?
    private var chunkSummaries:
        [PrimeNativeNeuralGateInvariantFramedStreamSummary] = []
    private var pendingGlobal: [Data] = []
    private var pendingChunk: [Data] = []
    private var globalCursor = 0
    private var chunkCursor = 0
    private var pendingGlobalByteCount = 0
    private var pendingChunkByteCount = 0
    private var matchedRecordCount = 0

    public init(
        decodedLeaves:
            PrimeNativeNeuralGateHistoricalDecodedCanonicalLeaves
    ) throws {
        self.decodedLeaves = decodedLeaves
        let expected = UInt64(
            decodedLeaves.invariantManifest.manifest.recordCount
        )
        globalReader =
            PrimeNativeNeuralGateInvariantFramedRecordReader(
                kind: .global,
                limits: .stageB,
                requireCanonicalOrder: true,
                requiredDeclaredRecordCount: expected
            )
        currentChunkReader = try Self.makeChunkReader(
            decodedLeaves: decodedLeaves,
            ordinal: 0
        )
    }

    /// Consumes one bounded fragment under its exact frozen artifact key.
    /// Canonical leaves are rejected here; only the role's global stream and
    /// the currently expected chunk ordinal are admissible.
    public func consume(
        _ fragment:
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput
    ) throws {
        try requireActiveForFeed()
        let role = decodedLeaves.invocationRole
        switch fragment.key {
        case let .invariantRecordsGlobal(candidateRole)
        where candidateRole == role:
            try consumeGlobalBytes(fragment.bytes)
        case let .invariantChunk(candidateRole, ordinal)
        where candidateRole == role:
            guard ordinal == nextChunkOrdinal else {
                return try poisonAndThrow(
                    .invalidChunkOrdinal(ordinal)
                )
            }
            try consumeCurrentChunkBytes(fragment.bytes)
        default:
            let context: String
            do {
                context = try
                    PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder
                    .path(for: fragment.key)
            } catch {
                return try poisonAndThrow(
                    .invalidArtifactBinding("stream_artifact_key")
                )
            }
            return try poisonAndThrow(
                .unexpectedArtifactKey(context)
            )
        }
    }

    private func consumeGlobalBytes(_ bytes: Data) throws {
        try requireActiveForFeed()
        try validateFeedSize(bytes)
        let expected = decodedLeaves.invariantManifest
            .globalStream.byteCount
        let next = globalInputByteCount.addingReportingOverflow(
            UInt64(bytes.count)
        )
        guard !next.overflow,
              next.partialValue <= expected
        else {
            return try poisonAndThrow(
                .invalidStreamState("global_byte_count")
            )
        }
        do {
            try globalReader.consume(bytes) {
                [unowned self] record in
                try enqueueGlobal(record)
            }
            globalInputByteCount = next.partialValue
        } catch {
            state = .poisoned
            throw translated(
                error,
                context: "global_consume"
            )
        }
    }

    private func consumeCurrentChunkBytes(_ bytes: Data) throws {
        try requireActiveForFeed()
        try validateFeedSize(bytes)
        guard let reader = currentChunkReader,
              Int(nextChunkOrdinal)
                < decodedLeaves.invariantManifest
                .orderedChunks.count
        else {
            return try poisonAndThrow(
                .invalidStreamState("no_current_chunk")
            )
        }
        let expected = decodedLeaves.invariantManifest
            .orderedChunks[Int(nextChunkOrdinal)].byteCount
        let next = currentChunkInputByteCount
            .addingReportingOverflow(UInt64(bytes.count))
        guard !next.overflow,
              next.partialValue <= expected
        else {
            return try poisonAndThrow(
                .invalidStreamState("chunk_byte_count")
            )
        }
        do {
            try reader.consume(bytes) {
                [unowned self] record in
                try enqueueChunk(record)
            }
            currentChunkInputByteCount = next.partialValue
        } catch {
            state = .poisoned
            throw translated(
                error,
                context: "chunk_consume"
            )
        }
    }

    public func finishCurrentChunk() throws {
        try requireActive()
        guard let reader = currentChunkReader,
              Int(nextChunkOrdinal)
                < decodedLeaves.invariantManifest
                .manifest.chunks.count
        else {
            return try poisonAndThrow(
                .invalidStreamState("no_current_chunk")
            )
        }
        do {
            let summary = try reader.finish()
            try drainMatchedRecords()
            let expectedManifest = decodedLeaves
                .invariantManifest.manifest
                .chunks[Int(nextChunkOrdinal)]
            let expectedReference = decodedLeaves
                .invariantManifest.orderedChunks[
                    Int(nextChunkOrdinal)
                ]
            guard summary.kind == .chunk,
                  summary.chunkOrdinal == nextChunkOrdinal,
                  summary.observedRecordCount
                    == expectedManifest.recordCount,
                  summary.declaredRecordCount
                    == UInt64(expectedManifest.recordCount),
                  summary.streamSHA256 == expectedManifest.sha256,
                  summary.streamSHA256
                    == expectedReference.contentSHA256,
                  summary.byteCount
                    == UInt64(expectedManifest.byteCount),
                  summary.byteCount == expectedReference.byteCount,
                  currentChunkInputByteCount
                    == expectedReference.byteCount,
                  pendingChunkCount == 0
            else {
                return try poisonAndThrow(
                    .invalidStreamState("chunk_summary")
                )
            }
            chunkSummaries.append(summary)
            nextChunkOrdinal += 1
            currentChunkInputByteCount = 0
            if Int(nextChunkOrdinal)
                < decodedLeaves.invariantManifest
                .manifest.chunks.count
            {
                currentChunkReader = try Self.makeChunkReader(
                    decodedLeaves: decodedLeaves,
                    ordinal: nextChunkOrdinal
                )
            } else {
                currentChunkReader = nil
            }
            compactQueues()
        } catch {
            state = .poisoned
            throw translated(
                error,
                context: "chunk_finish"
            )
        }
    }

    @discardableResult
    public func finishGlobal() throws
        -> PrimeNativeNeuralGateInvariantFramedStreamSummary
    {
        switch state {
        case let .finished(summary):
            return summary.global
        case .poisoned:
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .decoderPoisoned
        case .active:
            break
        }
        if let globalSummary {
            return globalSummary
        }
        do {
            let summary = try globalReader.finish()
            let manifest = decodedLeaves.invariantManifest.manifest
            let reference = decodedLeaves.invariantManifest.globalStream
            guard summary.kind == .global,
                  summary.chunkOrdinal == nil,
                  summary.observedRecordCount == manifest.recordCount,
                  summary.declaredRecordCount
                    == UInt64(manifest.recordCount),
                  summary.streamSHA256
                    == manifest.globalStreamSHA256,
                  summary.streamSHA256 == reference.contentSHA256,
                  summary.byteCount
                    == UInt64(manifest.globalStreamByteCount),
                  summary.byteCount == reference.byteCount,
                  globalInputByteCount == reference.byteCount
            else {
                return try poisonAndThrow(
                    .invalidStreamState("global_summary")
                )
            }
            globalSummary = summary
            return summary
        } catch {
            state = .poisoned
            throw translated(
                error,
                context: "global_finish"
            )
        }
    }

    public func finish() throws
        -> PrimeNativeNeuralGateHistoricalDecodedInvariantStreams
    {
        switch state {
        case let .finished(value):
            return value
        case .poisoned:
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .decoderPoisoned
        case .active:
            break
        }
        do {
            guard currentChunkReader == nil,
                  Int(nextChunkOrdinal)
                    == decodedLeaves.invariantManifest
                    .manifest.chunks.count,
                  chunkSummaries.count
                    == decodedLeaves.invariantManifest
                    .manifest.chunks.count
            else {
                return try poisonAndThrow(
                    .invalidStreamState("chunk_coverage")
                )
            }
            let global = try finishGlobal()
            try drainMatchedRecords()
            guard pendingGlobalCount == 0,
                  pendingChunkCount == 0,
                  matchedRecordCount
                    == decodedLeaves.invariantManifest
                    .manifest.recordCount
            else {
                return try poisonAndThrow(
                    .invalidStreamState("record_coverage")
                )
            }
            let role = decodedLeaves.invocationRole
            let streamBindings = try [
                PrimeNativeNeuralGateHistoricalSemanticArtifactBinding(
                    key: .invariantRecordsGlobal(role),
                    byteCount: global.byteCount,
                    sha256: global.streamSHA256
                ),
            ] + chunkSummaries.enumerated().map { index, summary in
                try PrimeNativeNeuralGateHistoricalSemanticArtifactBinding(
                    key: .invariantChunk(role, UInt32(index)),
                    byteCount: summary.byteCount,
                    sha256: summary.streamSHA256
                )
            }
            let value =
                PrimeNativeNeuralGateHistoricalDecodedInvariantStreams(
                    global: global,
                    orderedChunks: chunkSummaries,
                    matchedRecordCount: matchedRecordCount,
                    streamArtifactBindings: streamBindings
                )
            state = .finished(value)
            return value
        } catch {
            if case .finished = state {
                throw error
            }
            state = .poisoned
            throw translated(
                error,
                context: "stream_finish"
            )
        }
    }

    private static func makeChunkReader(
        decodedLeaves:
            PrimeNativeNeuralGateHistoricalDecodedCanonicalLeaves,
        ordinal: UInt32
    ) throws -> PrimeNativeNeuralGateInvariantFramedRecordReader {
        guard Int(ordinal)
            < decodedLeaves.invariantManifest
            .manifest.chunks.count
        else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidChunkOrdinal(ordinal)
        }
        let count = decodedLeaves.invariantManifest
            .manifest.chunks[Int(ordinal)].recordCount
        return PrimeNativeNeuralGateInvariantFramedRecordReader(
            kind: .chunk,
            limits: .stageB,
            requireCanonicalOrder: true,
            requiredDeclaredRecordCount: UInt64(count)
        )
    }

    private var pendingGlobalCount: Int {
        pendingGlobal.count - globalCursor
    }

    private var pendingChunkCount: Int {
        pendingChunk.count - chunkCursor
    }

    private func enqueueGlobal(_ record: Data) throws {
        if chunkCursor < pendingChunk.count {
            let chunk = pendingChunk[chunkCursor]
            guard record == chunk else {
                throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                    .globalChunkRecordMismatch(matchedRecordCount)
            }
            pendingChunkByteCount -= chunk.count
            chunkCursor += 1
            matchedRecordCount += 1
            compactQueues()
            return
        }
        try preflightPendingAppend(
            recordByteCount: record.count,
            currentCount: pendingGlobalCount,
            currentByteCount: pendingGlobalByteCount
        )
        pendingGlobal.append(record)
        pendingGlobalByteCount += record.count
    }

    private func enqueueChunk(_ record: Data) throws {
        if globalCursor < pendingGlobal.count {
            let global = pendingGlobal[globalCursor]
            guard global == record else {
                throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                    .globalChunkRecordMismatch(matchedRecordCount)
            }
            pendingGlobalByteCount -= global.count
            globalCursor += 1
            matchedRecordCount += 1
            compactQueues()
            return
        }
        try preflightPendingAppend(
            recordByteCount: record.count,
            currentCount: pendingChunkCount,
            currentByteCount: pendingChunkByteCount
        )
        pendingChunk.append(record)
        pendingChunkByteCount += record.count
    }

    private func drainMatchedRecords() throws {
        while globalCursor < pendingGlobal.count,
              chunkCursor < pendingChunk.count
        {
            let global = pendingGlobal[globalCursor]
            let chunk = pendingChunk[chunkCursor]
            guard global == chunk else {
                throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                    .globalChunkRecordMismatch(
                        matchedRecordCount
                    )
            }
            pendingGlobalByteCount -= global.count
            pendingChunkByteCount -= chunk.count
            globalCursor += 1
            chunkCursor += 1
            matchedRecordCount += 1
        }
        compactQueues()
    }

    private func compactQueues() {
        if globalCursor > 4_096 {
            pendingGlobal.removeFirst(globalCursor)
            globalCursor = 0
        }
        if chunkCursor > 4_096 {
            pendingChunk.removeFirst(chunkCursor)
            chunkCursor = 0
        }
        if globalCursor == pendingGlobal.count {
            pendingGlobal.removeAll(keepingCapacity: true)
            globalCursor = 0
        }
        if chunkCursor == pendingChunk.count {
            pendingChunk.removeAll(keepingCapacity: true)
            chunkCursor = 0
        }
    }

    private func preflightPendingAppend(
        recordByteCount: Int,
        currentCount: Int,
        currentByteCount: Int
    ) throws {
        let nextCount = currentCount.addingReportingOverflow(1)
        let nextBytes = currentByteCount.addingReportingOverflow(
            recordByteCount
        )
        guard !nextCount.overflow,
              !nextBytes.overflow,
              nextCount.partialValue
                <= Self.maximumPendingRecordCount,
              nextBytes.partialValue
                <= Self.maximumPendingRecordBytes
        else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidStreamState("pending_queue_bound")
        }
    }

    private func validateFeedSize(_ bytes: Data) throws {
        guard bytes.count
            <= PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder
            .descriptorFeedMaximumByteCount
        else {
            return try poisonAndThrow(
                .feedTooLarge(bytes.count)
            )
        }
    }

    private func requireActiveForFeed() throws {
        switch state {
        case .active:
            return
        case .finished:
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .decoderFinished
        case .poisoned:
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .decoderPoisoned
        }
    }

    private func requireActive() throws {
        try requireActiveForFeed()
    }

    private func poisonAndThrow<T>(
        _ error:
            PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
    ) throws -> T {
        state = .poisoned
        throw error
    }

    private func translated(
        _ error: Error,
        context: String
    ) -> PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError {
        if let typed = error as?
            PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
        {
            return typed
        }
        if let framed = error as?
            PrimeNativeNeuralGateReplayMechanicsError
        {
            return .framedStreamFailure(
                context: context,
                cause: framed
            )
        }
        return .invalidStreamState(context)
    }

    public func finishSemanticArtifactSet() throws
        -> PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet
    {
        try PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet(
            canonicalLeaves: decodedLeaves,
            invariantStreams: finish()
        )
    }
}
