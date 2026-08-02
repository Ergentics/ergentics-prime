// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeNativeNeuralGateHistoricalEvidenceExportMechanics
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateSemanticRecordContracts

public struct PrimeNativeNeuralGateHistoricalProjectionContext:
    Equatable,
    Sendable
{
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalArtifactRole
    public let sourceBytesResolved:
        PrimeNativeNeuralGateSemanticObservationState
    public let adaptationProofRecomputed:
        PrimeNativeNeuralGateSemanticObservationState

    public init(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole,
        sourceBytesResolved:
            PrimeNativeNeuralGateSemanticObservationState,
        adaptationProofRecomputed:
            PrimeNativeNeuralGateSemanticObservationState
    ) {
        self.invocationRole = invocationRole
        self.sourceBytesResolved = sourceBytesResolved
        self.adaptationProofRecomputed =
            adaptationProofRecomputed
    }
}

/// Exact in-memory bytes and their namespace binding. This value cannot write,
/// publish, seal, or issue a receipt.
public struct PrimeNativeNeuralGateHistoricalProjectedArtifact:
    Equatable,
    Sendable
{
    public let specification:
        PrimeNativeNeuralGateArtifactSpec
    public let bytes: Data
    public let sha256: String
    public let descriptorContentVerified:
        PrimeNativeNeuralGateSemanticObservationState
    public let durablePublicationObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool

    public var relativePath: String {
        specification.relativePath
    }

    public var schemaID: String {
        specification.schemaID
    }

    public var byteCount: UInt64 {
        UInt64(bytes.count)
    }

    init(
        specification:
            PrimeNativeNeuralGateArtifactSpec,
        bytes: Data
    ) throws {
        self.specification = specification
        self.bytes = bytes
        sha256 = PrimeNativeNeuralGateInvariantCodec
            .sha256(bytes)
        descriptorContentVerified = .unavailable
        durablePublicationObserved = .unavailable
        mechanicsPassAuthorized = false
        terminalReceiptAuthorized = false
        sourceBindingV7Issued = false
        try validate()
    }

    public func validate() throws {
        try specification.validate(
            maximumBoundedInMemoryByteCount:
                PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
                .frozenV1.maximumStatisticsJSONByteCount
        )
        let embeddedSchemaMatches: Bool
        if specification.encoding == .canonicalJSON,
           let object = try? JSONSerialization.jsonObject(with: bytes),
           let dictionary = object as? [String: Any],
           let embeddedSchemaID = dictionary["schema_id"] as? String
        {
            embeddedSchemaMatches =
                embeddedSchemaID == specification.schemaID
        } else {
            embeddedSchemaMatches =
                specification.encoding != .canonicalJSON
        }
        guard !bytes.isEmpty,
              UInt64(bytes.count) <= specification.maximumByteCount,
              sha256 == PrimeNativeNeuralGateInvariantCodec
                .sha256(bytes),
              embeddedSchemaMatches,
              descriptorContentVerified == .unavailable,
              durablePublicationObserved == .unavailable,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued
        else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .invalidArtifactSet(relativePath)
        }
    }

    fileprivate func semanticReference() throws
        -> PrimeNativeNeuralGateSemanticArtifactReference
    {
        try PrimeNativeNeuralGateSemanticArtifactReference(
            schemaID: schemaID,
            relativePath: relativePath,
            contentSHA256: sha256,
            byteCount: byteCount,
            maximumByteCount:
                specification.maximumByteCount,
            descriptorContentVerified: .unavailable,
            durablePublicationObserved: .unavailable
        )
    }
}

public struct PrimeNativeNeuralGateHistoricalProjectedArtifactSet:
    Equatable,
    Sendable
{
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalArtifactRole
    public let orderedArtifacts:
        [PrimeNativeNeuralGateHistoricalProjectedArtifact]
    public let artifactWritePerformed: Bool
    public let evidencePublished: Bool
    public let durablePublicationObserved: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    init(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole,
        orderedArtifacts:
            [PrimeNativeNeuralGateHistoricalProjectedArtifact]
    ) throws {
        self.invocationRole = invocationRole
        self.orderedArtifacts = orderedArtifacts
        artifactWritePerformed = false
        evidencePublished = false
        durablePublicationObserved = false
        mechanicsPassAuthorized = false
        terminalReceiptAuthorized = false
        sourceBindingV7Issued = false
        scientificAuthorityAuthorized = false
        productAuthorityAuthorized = false
        try validate()
    }

    public func artifact(
        for key:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
    ) throws -> PrimeNativeNeuralGateHistoricalProjectedArtifact {
        let spec = try
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1.spec(for: key)
        guard let value = orderedArtifacts.first(where: {
            $0.relativePath == spec.relativePath
        }) else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .invalidArtifactSet(spec.relativePath)
        }
        return value
    }

    public func validate() throws {
        let namespace =
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1
        try namespace.validate()
        try orderedArtifacts.forEach { try $0.validate() }
        let expectedSpecs = try
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .allKeys(for: invocationRole).map {
                try namespace.spec(for: $0)
            }
        guard orderedArtifacts.count == 22,
              Set(orderedArtifacts.map(\.relativePath)).count == 22,
              orderedArtifacts.map(\.specification)
                == expectedSpecs,
              !artifactWritePerformed,
              !evidencePublished,
              !durablePublicationObserved,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .invalidArtifactSet("complete_set")
        }
    }
}

/// Historical-only, non-writing semantic projection. The exporter evidence is
/// already source-derived; this codec verifies exact joins and encodes an
/// authority-free artifact set without changing worker reachability.
public enum PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection {
    public static func project(
        evidence:
            PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,
        context: PrimeNativeNeuralGateHistoricalProjectionContext
    ) throws -> PrimeNativeNeuralGateHistoricalProjectedArtifactSet {
        let role = context.invocationRole
        let invariantBundle = try verifyInvariantEvidence(
            records: evidence.orderedInvariantRecords,
            asciiFlags: evidence.orderedInvariantRecordASCIIFlags,
            baselineBundle: evidence.baselineInvariantBundle
        )
        let mutationObservation = try makeMutationObservation(
            orderedMutationIdentities:
                evidence.orderedMutationIdentities,
            streamIdentities:
                evidence.perMutationStreamIdentities,
            fingerprints: evidence.perMutationFingerprints,
            observedFailureSets:
                evidence.perMutationObservedFailedLegIDs,
            baselineBundle: invariantBundle,
            role: role
        )
        let criticalLegs = try makeCriticalLegs(
            evidence.historicalCriticalLegValues
        )
        let statisticsEnvelope = try
            PrimeNativeNeuralGateHistoricalKeyedThreeSeedStatisticsEnvelope
            .make(
                invocationRole: role,
                values:
                    evidence.historicalStatisticsAndVerdictValues,
                historicalCriticalLegValues:
                    evidence.historicalCriticalLegValues
            )
        return try assembleArtifacts(
            invariantBundle: invariantBundle,
            mutationObservation: mutationObservation,
            criticalLegs: criticalLegs,
            statisticsEnvelope: statisticsEnvelope,
            context: context
        )
    }

    static func assembleArtifacts(
        invariantBundle: PrimeNativeNeuralGateInvariantBundle,
        mutationObservation:
            PrimeNativeNeuralGateHistoricalMutationSweepObservation,
        criticalLegs:
            [PrimeNativeNeuralGateSemanticCriticalLegObservation],
        statisticsEnvelope:
            PrimeNativeNeuralGateHistoricalKeyedThreeSeedStatisticsEnvelope,
        context: PrimeNativeNeuralGateHistoricalProjectionContext
    ) throws -> PrimeNativeNeuralGateHistoricalProjectedArtifactSet {
        let namespace =
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1
        try namespace.validate()
        let role = context.invocationRole
        let decodedRecords = try PrimeNativeNeuralGateInvariantCodec
            .validate(
                manifest: invariantBundle.manifest,
                fingerprintObservation:
                    invariantBundle.fingerprintObservation,
                globalStream: invariantBundle.globalStream,
                chunkStreams: invariantBundle.chunkStreams
            )
        try mutationObservation.validate()
        try criticalLegs.forEach { try $0.validate() }
        try statisticsEnvelope.validate()
        let criticalLegCarrierValues =
            statisticsEnvelope.historicalCriticalLegValues
        let baselineStreamSHA256 =
            invariantBundle.manifest.globalStreamSHA256
        let baselineFingerprint =
            invariantBundle.fingerprintObservation.direct
        guard decodedRecords == invariantBundle.canonicalRecords,
              decodedRecords.count == namespace.exactInvariantRecordCount,
              invariantBundle.manifest.recordCount
                == namespace.exactInvariantRecordCount,
              invariantBundle.chunkStreams.count
                == namespace.exactInvariantChunkCount,
              invariantBundle.manifest.chunks.count
                == namespace.exactInvariantChunkCount,
              invariantBundle.manifest.chunks.map(\.ordinal)
                == (0 ..< namespace.exactInvariantChunkCount)
                .map(UInt32.init),
              try invariantBundle.manifest.chunks.allSatisfy({
                  $0.recordCount
                    == (try namespace.invariantRecordCount(
                        forChunkOrdinal: $0.ordinal
                    ))
              }),
              mutationObservation.invocationRole == role,
              mutationObservation.observations.allSatisfy({
                  $0.baselineStreamSHA256
                    == baselineStreamSHA256
                      && $0.restoredStreamSHA256
                        == baselineStreamSHA256
                      && $0.baselineFingerprint
                        == baselineFingerprint
                      && $0.restoredFingerprint
                        == baselineFingerprint
              }),
              statisticsEnvelope.invocationRole == role,
              criticalLegs.count == 10,
              criticalLegCarrierValues.count == criticalLegs.count,
              criticalLegs.map(\.legID)
                == PrimeNativeNeuralGateSemanticVerdictPolicy
                .orderedCriticalLegIDs,
              zip(
                  criticalLegCarrierValues,
                  criticalLegs
              ).allSatisfy({ carrier, semantic in
                  semantic.ordinal == carrier.ordinal
                      && semantic.legID == carrier.legID
                      && semantic.passed == .unavailable
                      && semantic.evidence.isEmpty
                      && semantic.detail
                        == "source_derived_historical_carrier_passed_"
                            + (carrier.passed ? "true" : "false")
              })
        else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .invalidArtifactSet("projection_inputs")
        }
        let materialManifest = try
            PrimeNativeNeuralGateHistoricalMaterialIdentityManifest(
                invocationRole: role,
                sourceBytesResolved: context.sourceBytesResolved,
                adaptationProofRecomputed:
                    context.adaptationProofRecomputed
            )
        let material = try artifact(
            key: .materialIdentityManifest(role),
            bytes: canonicalJSON(materialManifest),
            namespace: namespace
        )

        let global = try artifact(
            key: .invariantRecordsGlobal(role),
            bytes: invariantBundle.globalStream,
            namespace: namespace
        )
        let chunks = try invariantBundle.chunkStreams
            .enumerated().map { index, bytes in
                try artifact(
                    key: .invariantChunk(role, UInt32(index)),
                    bytes: bytes,
                    namespace: namespace
                )
            }
        let invariantObservation = try
            PrimeNativeNeuralGateHistoricalInvariantObservation(
                invocationRole: role,
                manifest: invariantBundle.manifest,
                globalStream: global.semanticReference(),
                orderedChunks: try chunks.map {
                    try $0.semanticReference()
                },
                recordsObserved: .unavailable,
                completeHistoricalRecordSetObserved: .unavailable
            )
        let invariantManifest = try artifact(
            key: .invariantRecordsManifest(role),
            bytes: canonicalJSON(invariantObservation),
            namespace: namespace
        )

        let fingerprintObservation = try
            PrimeNativeNeuralGateHistoricalFingerprintObservation(
                invocationRole: role,
                observation:
                    invariantBundle.fingerprintObservation,
                directRecomputationObserved: .unavailable,
                acceleratedRecomputationObserved: .unavailable,
                exactEqualityObserved: .unavailable,
                historicalSZRecomputed: .unavailable
            )
        let fingerprint = try artifact(
            key: .fingerprintObservation(role),
            bytes: canonicalJSON(fingerprintObservation),
            namespace: namespace
        )

        let mutation = try artifact(
            key: .mutationObservations(role),
            bytes: canonicalJSON(mutationObservation),
            namespace: namespace
        )

        let statistics = try artifact(
            key: .statisticsVerdictObservation(role),
            bytes: statisticsEnvelope.canonicalData(),
            namespace: namespace
        )

        // Gate is encoded last because its five references must bind the
        // already encoded exact bytes above.
        let gate = try
            PrimeNativeNeuralGateHistoricalGateObservation(
                invocationRole: role,
                materialIdentity: material.semanticReference(),
                invariantManifest:
                    invariantManifest.semanticReference(),
                fingerprintObservation:
                    fingerprint.semanticReference(),
                mutationObservation: mutation.semanticReference(),
                statisticsVerdictObservation:
                    statistics.semanticReference(),
                criticalLegs: criticalLegs,
                sourceBoundCriticalLegEvidence: .unavailable,
                modelExecutionObserved: .unavailable
            )
        let gateArtifact = try artifact(
            key: .gateObservation(role),
            bytes: canonicalJSON(gate),
            namespace: namespace
        )

        let projected =
            [material, gateArtifact, invariantManifest, global]
            + [fingerprint, mutation, statistics]
            + chunks
        var projectedByPath:
            [String: PrimeNativeNeuralGateHistoricalProjectedArtifact] = [:]
        for value in projected {
            guard projectedByPath.updateValue(
                value,
                forKey: value.relativePath
            ) == nil else {
                throw PrimeNativeNeuralGateHistoricalProjectionError
                    .invalidArtifactSet(value.relativePath)
            }
        }
        let canonicallyOrdered = try
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .allKeys(for: role).map { key in
                let path = try namespace.spec(for: key).relativePath
                guard let value = projectedByPath[path] else {
                    throw PrimeNativeNeuralGateHistoricalProjectionError
                        .invalidArtifactSet(path)
                }
                return value
            }
        return try PrimeNativeNeuralGateHistoricalProjectedArtifactSet(
            invocationRole: role,
            orderedArtifacts: canonicallyOrdered
        )
    }

    static func verifyInvariantEvidence(
        records: [Data],
        asciiFlags: [Bool],
        baselineBundle: PrimeNativeNeuralGateInvariantBundle
    ) throws -> PrimeNativeNeuralGateInvariantBundle {
        let namespace =
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1
        try namespace.validate()
        guard records.count
                == namespace.exactInvariantRecordCount,
              asciiFlags.count == records.count,
              zip(
                  records,
                  asciiFlags
              ).allSatisfy({ record, flag in
                  record.allSatisfy { $0 < 0x80 } == flag
              })
        else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .invalidInvariantEvidence("record_or_ascii_coverage")
        }
        let recomputed = try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: records)
        guard recomputed == baselineBundle,
              recomputed.manifest.recordCount
                == namespace.exactInvariantRecordCount,
              recomputed.chunkStreams.count
                == namespace.exactInvariantChunkCount,
              try recomputed.manifest.chunks.allSatisfy({ chunk in
                  chunk.recordCount
                    == (try namespace.invariantRecordCount(
                        forChunkOrdinal: chunk.ordinal
                    ))
              })
        else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .invalidInvariantEvidence("bundle_recomputation")
        }
        return recomputed
    }

    static func makeMutationObservation(
        orderedMutationIdentities: [String],
        streamIdentities:
            [PrimeNativeNeuralGateHistoricalEvidenceExporter
                .MutationStreamIdentity],
        fingerprints:
            [PrimeNativeNeuralGateHistoricalEvidenceExporter
                .MutationFingerprintSet],
        observedFailureSets:
            [PrimeNativeNeuralGateHistoricalEvidenceExporter
                .MutationObservedFailureSet],
        baselineBundle: PrimeNativeNeuralGateInvariantBundle,
        role: PrimeNativeNeuralGateHistoricalArtifactRole
    ) throws -> PrimeNativeNeuralGateHistoricalMutationSweepObservation {
        let catalog = PrimeNativeNeuralGateMutationCatalog
            .historicalEntries
        guard orderedMutationIdentities
                == catalog.map(\.mutationID)
        else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .invalidMutationEvidence("ordered_identity_catalog")
        }
        let streamsByOrdinal = try exactMutationMap(
            streamIdentities,
            family: "streams",
            ordinal: \.ordinal,
            identity: \.mutationID
        )
        let fingerprintsByOrdinal = try exactMutationMap(
            fingerprints,
            family: "fingerprints",
            ordinal: \.ordinal,
            identity: \.mutationID
        )
        let failuresByOrdinal = try exactMutationMap(
            observedFailureSets,
            family: "failures",
            ordinal: \.ordinal,
            identity: \.mutationID
        )
        let baselineStreamSHA256 =
            baselineBundle.manifest.globalStreamSHA256
        let baselineObservation =
            baselineBundle.fingerprintObservation
        let observations = try catalog.map { entry in
            let ordinal = Int(entry.ordinal)
            guard let stream = streamsByOrdinal[ordinal],
                  let fingerprint = fingerprintsByOrdinal[ordinal],
                  let failure = failuresByOrdinal[ordinal],
                  stream.mutationID == entry.mutationID,
                  fingerprint.mutationID == entry.mutationID,
                  failure.mutationID == entry.mutationID,
                  stream.baselineStreamSHA256
                    == baselineStreamSHA256,
                  stream.restoredStreamSHA256
                    == baselineStreamSHA256,
                  fingerprint.baseline == baselineObservation,
                  fingerprint.restored == baselineObservation,
                  isCanonicalFingerprintObservation(
                      fingerprint.mutated,
                      streamSHA256:
                          stream.mutatedStreamSHA256
                  )
            else {
                throw PrimeNativeNeuralGateHistoricalProjectionError
                    .invalidMutationEvidence(entry.mutationID)
            }
            return try
                PrimeNativeNeuralGateHistoricalMutationRecordObservation(
                    ordinal: entry.ordinal,
                    mutationID: entry.mutationID,
                    allowedFailedLegIDs: [entry.expectedFailedLegID],
                    observedFailedLegIDs:
                        failure.orderedObservedFailedLegIDs,
                    baselineStreamSHA256:
                        stream.baselineStreamSHA256,
                    mutatedStreamSHA256:
                        stream.mutatedStreamSHA256,
                    restoredStreamSHA256:
                        stream.restoredStreamSHA256,
                    baselineFingerprint: fingerprint.baseline.direct,
                    mutatedFingerprint: fingerprint.mutated.direct,
                    restoredFingerprint: fingerprint.restored.direct,
                    mutationExecutionObserved: .unavailable,
                    independentDetectionObserved: .unavailable
                )
        }
        return try PrimeNativeNeuralGateHistoricalMutationSweepObservation(
            invocationRole: role,
            observations: observations,
            exactCatalogCoverageObserved: .unavailable,
            exactFailureSetsObserved: .unavailable
        )
    }

    private static func isCanonicalFingerprintObservation(
        _ observation:
            PrimeNativeNeuralGateFingerprintObservation,
        streamSHA256: String
    ) -> Bool {
        observation
            == PrimeNativeNeuralGateFingerprintObservation(
                orderedMultisetStreamSHA256: streamSHA256,
                direct: observation.direct,
                accelerated: observation.direct
            )
    }

    private static func exactMutationMap<T>(
        _ values: [T],
        family: String,
        ordinal: KeyPath<T, Int>,
        identity: KeyPath<T, String>
    ) throws -> [Int: T] {
        let catalog = PrimeNativeNeuralGateMutationCatalog
            .historicalEntries
        var result: [Int: T] = [:]
        for value in values {
            let valueOrdinal = value[keyPath: ordinal]
            guard valueOrdinal > 0,
                  valueOrdinal <= catalog.count,
                  value[keyPath: identity]
                    == catalog[valueOrdinal - 1].mutationID,
                  result.updateValue(
                      value,
                      forKey: valueOrdinal
                  ) == nil
            else {
                throw PrimeNativeNeuralGateHistoricalProjectionError
                    .invalidMutationEvidence(family)
            }
        }
        guard result.count == catalog.count else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .invalidMutationEvidence(family + "_coverage")
        }
        return result
    }

    static func makeCriticalLegs(
        _ values:
            [PrimeNativeNeuralGateHistoricalEvidenceExporter.CriticalLegValue]
    ) throws -> [PrimeNativeNeuralGateSemanticCriticalLegObservation] {
        let expected = PrimeNativeNeuralGateSemanticVerdictPolicy
            .orderedCriticalLegIDs
        var byOrdinal:
            [Int: PrimeNativeNeuralGateHistoricalEvidenceExporter
                .CriticalLegValue] = [:]
        for value in values {
            guard value.ordinal > 0,
                  value.ordinal <= expected.count,
                  value.legID == expected[value.ordinal - 1],
                  byOrdinal.updateValue(
                      value,
                      forKey: value.ordinal
                  ) == nil
            else {
                throw PrimeNativeNeuralGateHistoricalProjectionError
                    .invalidCriticalLegEvidence(value.legID)
            }
        }
        guard byOrdinal.count == expected.count else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .invalidCriticalLegEvidence("coverage")
        }
        return try (1 ... expected.count).map { ordinal in
            guard let value = byOrdinal[ordinal] else {
                throw PrimeNativeNeuralGateHistoricalProjectionError
                    .invalidCriticalLegEvidence("missing")
            }
            return try PrimeNativeNeuralGateSemanticCriticalLegObservation(
                ordinal: ordinal,
                legID: value.legID,
                passed: .unavailable,
                detail:
                    "source_derived_historical_carrier_passed_"
                    + (value.passed ? "true" : "false"),
                evidence: []
            )
        }
    }

    private static func artifact(
        key:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey,
        bytes: Data,
        namespace:
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
    ) throws -> PrimeNativeNeuralGateHistoricalProjectedArtifact {
        try PrimeNativeNeuralGateHistoricalProjectedArtifact(
            specification: namespace.spec(for: key),
            bytes: bytes
        )
    }

    private static func canonicalJSON<T: Encodable>(
        _ value: T
    ) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        return try encoder.encode(value)
    }
}
