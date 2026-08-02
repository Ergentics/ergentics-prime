// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateSemanticRecordContracts

public enum
    PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError:
    Error,
    Equatable,
    Sendable
{
    case emptyArtifact(String)
    case artifactTooLarge(
        path: String,
        actualByteCount: Int,
        maximumByteCount: UInt64
    )
    case invalidUTF8(String)
    case invalidCanonicalJSON(String)
    case nonCanonicalJSON(String)
    case unexpectedArtifactKey(String)
    case duplicateArtifactKey(String)
    case missingArtifactKey(String)
    case invalidArtifactBinding(String)
    case invalidArtifactSet(String)
    case invalidSemanticLeaf(String)
    case feedTooLarge(Int)
    case invalidChunkOrdinal(UInt32)
    case invalidStreamState(String)
    case framedStreamFailure(
        context: String,
        cause: PrimeNativeNeuralGateReplayMechanicsError
    )
    case globalChunkRecordMismatch(Int)
    case decoderPoisoned
    case decoderFinished
}

/// Caller-supplied bytes keyed only by the frozen V16 namespace. This value
/// conveys no filesystem, descriptor, publication, or source authority.
public struct PrimeNativeNeuralGateHistoricalSemanticArtifactInput:
    Equatable,
    Sendable
{
    public let key:
        PrimeNativeNeuralGateHistoricalSemanticArtifactKey
    public let bytes: Data

    public init(
        key:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey,
        bytes: Data
    ) {
        self.key = key
        self.bytes = bytes
    }
}

/// An exact byte identity derived under the frozen namespace specification.
/// Paths, schemas, modes, and decoder policies are never caller supplied.
public struct PrimeNativeNeuralGateHistoricalSemanticArtifactBinding:
    Equatable,
    Sendable
{
    public let key:
        PrimeNativeNeuralGateHistoricalSemanticArtifactKey
    public let byteCount: UInt64
    public let sha256: String

    init(
        key:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey,
        byteCount: UInt64,
        sha256: String
    ) throws {
        let spec: PrimeNativeNeuralGateArtifactSpec
        do {
            spec = try
                PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
                .frozenV1.spec(for: key)
        } catch {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidArtifactBinding("artifact_key")
        }
        guard byteCount > 0,
              byteCount <= spec.maximumByteCount,
              Self.isLowercaseSHA256(sha256)
        else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidArtifactBinding(spec.relativePath)
        }
        self.key = key
        self.byteCount = byteCount
        self.sha256 = sha256
    }

    public var relativePath: String {
        get throws {
            try specification.relativePath
        }
    }

    public var specification: PrimeNativeNeuralGateArtifactSpec {
        get throws {
            try
                PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
                .frozenV1.spec(for: key)
        }
    }

    private static func isLowercaseSHA256(
        _ value: String
    ) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }
}

/// Six typed, canonical leaves after all producer-equivalent cross-leaf joins.
/// It is intentionally non-Codable and has no public memberwise initializer.
public struct PrimeNativeNeuralGateHistoricalDecodedCanonicalLeaves:
    Equatable,
    Sendable
{
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalArtifactRole
    public let materialIdentity:
        PrimeNativeNeuralGateHistoricalMaterialIdentityManifest
    public let gate:
        PrimeNativeNeuralGateHistoricalGateObservation
    public let invariantManifest:
        PrimeNativeNeuralGateHistoricalInvariantObservation
    public let fingerprint:
        PrimeNativeNeuralGateHistoricalFingerprintObservation
    public let mutations:
        PrimeNativeNeuralGateHistoricalMutationSweepObservation
    public let statistics:
        PrimeNativeNeuralGateHistoricalStatisticsArtifactEnvelope
    public let canonicalJSONBindings:
        [PrimeNativeNeuralGateHistoricalSemanticArtifactBinding]
    public let artifactWritePerformed: Bool
    public let evidencePublished: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    init(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole,
        materialIdentity:
            PrimeNativeNeuralGateHistoricalMaterialIdentityManifest,
        gate: PrimeNativeNeuralGateHistoricalGateObservation,
        invariantManifest:
            PrimeNativeNeuralGateHistoricalInvariantObservation,
        fingerprint:
            PrimeNativeNeuralGateHistoricalFingerprintObservation,
        mutations:
            PrimeNativeNeuralGateHistoricalMutationSweepObservation,
        statistics:
            PrimeNativeNeuralGateHistoricalStatisticsArtifactEnvelope,
        canonicalJSONBindings:
            [PrimeNativeNeuralGateHistoricalSemanticArtifactBinding]
    ) {
        self.invocationRole = invocationRole
        self.materialIdentity = materialIdentity
        self.gate = gate
        self.invariantManifest = invariantManifest
        self.fingerprint = fingerprint
        self.mutations = mutations
        self.statistics = statistics
        self.canonicalJSONBindings = canonicalJSONBindings
        artifactWritePerformed = false
        evidencePublished = false
        mechanicsPassAuthorized = false
        terminalReceiptAuthorized = false
        sourceBindingV7Issued = false
        scientificAuthorityAuthorized = false
        productAuthorityAuthorized = false
    }

    public func binding(
        for key:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
    ) throws
        -> PrimeNativeNeuralGateHistoricalSemanticArtifactBinding
    {
        guard let value = canonicalJSONBindings.first(
            where: { $0.key == key }
        ) else {
            let path = try
                PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder
                .path(for: key)
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .missingArtifactKey(path)
        }
        return value
    }
}

public enum PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder {
    public static let descriptorFeedMaximumByteCount = 65_536

    public static func decodeCanonicalLeaves(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole,
        artifacts:
            [PrimeNativeNeuralGateHistoricalSemanticArtifactInput]
    ) throws -> PrimeNativeNeuralGateHistoricalDecodedCanonicalLeaves {
        let keys = canonicalJSONKeys(for: invocationRole)
        let inputs = try exactInputMap(
            artifacts,
            expectedKeys: keys
        )
        let materialKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .materialIdentityManifest(invocationRole)
        let gateKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .gateObservation(invocationRole)
        let invariantKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .invariantRecordsManifest(invocationRole)
        let fingerprintKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .fingerprintObservation(invocationRole)
        let mutationKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .mutationObservations(invocationRole)
        let statisticsKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .statisticsVerdictObservation(invocationRole)

        let material = try decodeMaterial(
            input: try requiredInput(materialKey, from: inputs)
        )
        let gate = try decodeGate(
            input: try requiredInput(gateKey, from: inputs)
        )
        let invariant = try decodeInvariant(
            input: try requiredInput(invariantKey, from: inputs)
        )
        let fingerprint = try decodeFingerprint(
            input: try requiredInput(fingerprintKey, from: inputs)
        )
        let mutations = try decodeMutations(
            input: try requiredInput(mutationKey, from: inputs)
        )
        let statisticsInput = try requiredInput(
            statisticsKey,
            from: inputs
        )
        try preflightCanonicalJSON(statisticsInput)
        let statistics:
            PrimeNativeNeuralGateHistoricalStatisticsArtifactEnvelope
        do {
            statistics = try
                PrimeNativeNeuralGateHistoricalStatisticsArtifactEnvelope
                .decodeCanonical(statisticsInput.bytes)
        } catch let error as
            PrimeNativeNeuralGateHistoricalStatisticsArtifactError
        {
            let statisticsPath = try path(for: statisticsKey)
            switch error {
            case .invalidJSON:
                throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                    .invalidCanonicalJSON(statisticsPath)
            case .nonCanonicalJSON:
                throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                    .nonCanonicalJSON(statisticsPath)
            case .emptyArtifact:
                throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                    .emptyArtifact(statisticsPath)
            case let .artifactTooLarge(actual, maximum):
                throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                    .artifactTooLarge(
                        path: statisticsPath,
                        actualByteCount: actual,
                        maximumByteCount: UInt64(maximum)
                    )
            case .invalidEnvelope,
                 .canonicalEncodingFailed:
                throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                    .invalidSemanticLeaf(statisticsPath)
            }
        } catch {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidSemanticLeaf(try path(for: statisticsKey))
        }

        let bindings = try keys.map { key in
            try binding(
                for: requiredInput(key, from: inputs)
            )
        }
        let decoded =
            PrimeNativeNeuralGateHistoricalDecodedCanonicalLeaves(
                invocationRole: invocationRole,
                materialIdentity: material,
                gate: gate,
                invariantManifest: invariant,
                fingerprint: fingerprint,
                mutations: mutations,
                statistics: statistics,
                canonicalJSONBindings: bindings
            )
        try validateCrossLeafJoins(decoded)
        return decoded
    }

    static func canonicalJSONKeys(
        for role: PrimeNativeNeuralGateHistoricalArtifactRole
    ) -> [PrimeNativeNeuralGateHistoricalSemanticArtifactKey] {
        [
            .materialIdentityManifest(role),
            .gateObservation(role),
            .invariantRecordsManifest(role),
            .fingerprintObservation(role),
            .mutationObservations(role),
            .statisticsVerdictObservation(role),
        ]
    }

    static func role(
        for key:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
    ) -> PrimeNativeNeuralGateHistoricalArtifactRole {
        switch key {
        case let .materialIdentityManifest(role),
             let .gateObservation(role),
             let .invariantRecordsManifest(role),
             let .invariantRecordsGlobal(role),
             let .fingerprintObservation(role),
             let .mutationObservations(role),
             let .statisticsVerdictObservation(role),
             let .invariantChunk(role, _):
            return role
        }
    }

    static func exactInputMap(
        _ artifacts:
            [PrimeNativeNeuralGateHistoricalSemanticArtifactInput],
        expectedKeys:
            [PrimeNativeNeuralGateHistoricalSemanticArtifactKey]
    ) throws -> [
        PrimeNativeNeuralGateHistoricalSemanticArtifactKey:
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput
    ] {
        let expected = Set(expectedKeys)
        var result: [
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey:
                PrimeNativeNeuralGateHistoricalSemanticArtifactInput
        ] = [:]
        for artifact in artifacts {
            guard expected.contains(artifact.key) else {
                throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                    .unexpectedArtifactKey(
                        try path(for: artifact.key)
                    )
            }
            guard result.updateValue(
                artifact,
                forKey: artifact.key
            ) == nil else {
                throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                    .duplicateArtifactKey(
                        try path(for: artifact.key)
                    )
            }
        }
        for key in expectedKeys where result[key] == nil {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .missingArtifactKey(try path(for: key))
        }
        guard result.count == expectedKeys.count else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidArtifactSet("keyed_coverage")
        }
        return result
    }

    static func binding(
        for input:
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput
    ) throws
        -> PrimeNativeNeuralGateHistoricalSemanticArtifactBinding
    {
        let spec = try
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1.spec(for: input.key)
        guard !input.bytes.isEmpty else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .emptyArtifact(spec.relativePath)
        }
        guard UInt64(input.bytes.count) <= spec.maximumByteCount else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .artifactTooLarge(
                    path: spec.relativePath,
                    actualByteCount: input.bytes.count,
                    maximumByteCount: spec.maximumByteCount
                )
        }
        return try
            PrimeNativeNeuralGateHistoricalSemanticArtifactBinding(
                key: input.key,
                byteCount: UInt64(input.bytes.count),
                sha256:
                    PrimeNativeNeuralGateInvariantCodec
                    .sha256(input.bytes)
            )
    }

    static func path(
        for key:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
    ) throws -> String {
        do {
            return try
                PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
                .frozenV1.spec(for: key).relativePath
        } catch {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidArtifactBinding("artifact_key")
        }
    }

    private static func requiredInput(
        _ key:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey,
        from values: [
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey:
                PrimeNativeNeuralGateHistoricalSemanticArtifactInput
        ]
    ) throws -> PrimeNativeNeuralGateHistoricalSemanticArtifactInput {
        guard let value = values[key] else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .missingArtifactKey(try path(for: key))
        }
        return value
    }
}

private extension
    PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder
{
    struct MaterialWire: Decodable {
        let invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole
        let sourceBytesResolved: String
        let adaptationProofRecomputed: String

        private enum CodingKeys: String, CodingKey {
            case invocationRole = "invocation_role"
            case sourceBytesResolved = "source_bytes_resolved"
            case adaptationProofRecomputed =
                "adaptation_proof_recomputed"
        }
    }

    struct ReferenceWire: Decodable {
        let schemaID: String
        let relativePath: String
        let contentSHA256: String
        let byteCount: UInt64
        let maximumByteCount: UInt64
        let descriptorContentVerified: String
        let durablePublicationObserved: String

        private enum CodingKeys: String, CodingKey {
            case schemaID = "schema_id"
            case relativePath = "relative_path"
            case contentSHA256 = "content_sha256"
            case byteCount = "byte_count"
            case maximumByteCount = "maximum_byte_count"
            case descriptorContentVerified =
                "descriptor_content_verified"
            case durablePublicationObserved =
                "durable_publication_observed"
        }
    }

    struct InvariantWire: Decodable {
        let invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole
        let manifest: PrimeNativeNeuralGateInvariantManifest
        let globalStream: ReferenceWire
        let orderedChunks: [ReferenceWire]
        let recordsObserved: String
        let completeHistoricalRecordSetObserved: String

        private enum CodingKeys: String, CodingKey {
            case invocationRole = "invocation_role"
            case manifest
            case globalStream = "global_stream"
            case orderedChunks = "ordered_chunks"
            case recordsObserved = "records_observed"
            case completeHistoricalRecordSetObserved =
                "complete_historical_record_set_observed"
        }
    }

    struct FingerprintWire: Decodable {
        let invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole
        let observation:
            PrimeNativeNeuralGateFingerprintObservation
        let directRecomputationObserved: String
        let acceleratedRecomputationObserved: String
        let exactEqualityObserved: String
        let historicalSZRecomputed: String

        private enum CodingKeys: String, CodingKey {
            case invocationRole = "invocation_role"
            case observation
            case directRecomputationObserved =
                "direct_recomputation_observed"
            case acceleratedRecomputationObserved =
                "accelerated_recomputation_observed"
            case exactEqualityObserved =
                "exact_equality_observed"
            case historicalSZRecomputed =
                "historical_sz_recomputed"
        }
    }

    struct MutationRecordWire: Decodable {
        let ordinal: UInt32
        let mutationID: String
        let allowedFailedLegIDs: [String]
        let observedFailedLegIDs: [String]
        let baselineStreamSHA256: String
        let mutatedStreamSHA256: String
        let restoredStreamSHA256: String
        let baselineFingerprint:
            PrimeNativeNeuralGateFingerprint
        let mutatedFingerprint:
            PrimeNativeNeuralGateFingerprint
        let restoredFingerprint:
            PrimeNativeNeuralGateFingerprint
        let mutationExecutionObserved: String
        let independentDetectionObserved: String

        private enum CodingKeys: String, CodingKey {
            case ordinal
            case mutationID = "mutation_id"
            case allowedFailedLegIDs =
                "allowed_failed_leg_ids"
            case observedFailedLegIDs =
                "observed_failed_leg_ids"
            case baselineStreamSHA256 =
                "baseline_stream_sha256"
            case mutatedStreamSHA256 =
                "mutated_stream_sha256"
            case restoredStreamSHA256 =
                "restored_stream_sha256"
            case baselineFingerprint = "baseline_fingerprint"
            case mutatedFingerprint = "mutated_fingerprint"
            case restoredFingerprint = "restored_fingerprint"
            case mutationExecutionObserved =
                "mutation_execution_observed"
            case independentDetectionObserved =
                "independent_detection_observed"
        }
    }

    struct MutationsWire: Decodable {
        let invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole
        let observations: [MutationRecordWire]
        let exactCatalogCoverageObserved: String
        let exactFailureSetsObserved: String

        private enum CodingKeys: String, CodingKey {
            case invocationRole = "invocation_role"
            case observations
            case exactCatalogCoverageObserved =
                "exact_catalog_coverage_observed"
            case exactFailureSetsObserved =
                "exact_failure_sets_observed"
        }
    }

    struct CriticalLegWire: Decodable {
        let ordinal: Int
        let legID: String
        let passed: String
        let detail: String
        let evidence: [ReferenceWire]

        private enum CodingKeys: String, CodingKey {
            case ordinal
            case legID = "leg_id"
            case passed
            case detail
            case evidence
        }
    }

    struct GateWire: Decodable {
        let invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole
        let materialIdentity: ReferenceWire
        let invariantManifest: ReferenceWire
        let fingerprintObservation: ReferenceWire
        let mutationObservation: ReferenceWire
        let statisticsVerdictObservation: ReferenceWire
        let criticalLegs: [CriticalLegWire]
        let sourceBoundCriticalLegEvidence: String
        let modelExecutionObserved: String

        private enum CodingKeys: String, CodingKey {
            case invocationRole = "invocation_role"
            case materialIdentity = "material_identity"
            case invariantManifest = "invariant_manifest"
            case fingerprintObservation =
                "fingerprint_observation"
            case mutationObservation = "mutation_observation"
            case statisticsVerdictObservation =
                "statistics_verdict_observation"
            case criticalLegs = "critical_legs"
            case sourceBoundCriticalLegEvidence =
                "source_bound_critical_leg_evidence"
            case modelExecutionObserved =
                "model_execution_observed"
        }
    }

    static func preflightCanonicalJSON(
        _ input:
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput
    ) throws {
        let spec = try
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1.spec(for: input.key)
        guard !input.bytes.isEmpty else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .emptyArtifact(spec.relativePath)
        }
        guard UInt64(input.bytes.count) <= spec.maximumByteCount else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .artifactTooLarge(
                    path: spec.relativePath,
                    actualByteCount: input.bytes.count,
                    maximumByteCount: spec.maximumByteCount
                )
        }
        guard String(
            data: input.bytes,
            encoding: .utf8
        ) != nil else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidUTF8(spec.relativePath)
        }
    }

    static func decodeCanonical<Wire: Decodable, Value: Encodable>(
        _ input:
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput,
        as wireType: Wire.Type,
        reconstruct: (Wire) throws -> Value
    ) throws -> Value {
        try preflightCanonicalJSON(input)
        let artifactPath = try path(for: input.key)
        let wire: Wire
        do {
            wire = try JSONDecoder().decode(
                wireType,
                from: input.bytes
            )
        } catch {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidCanonicalJSON(artifactPath)
        }
        let value: Value
        do {
            value = try reconstruct(wire)
        } catch {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidSemanticLeaf(artifactPath)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        let canonical: Data
        do {
            canonical = try encoder.encode(value)
        } catch {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidSemanticLeaf(artifactPath)
        }
        guard canonical == input.bytes else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .nonCanonicalJSON(artifactPath)
        }
        return value
    }

    static func decodeMaterial(
        input:
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput
    ) throws
        -> PrimeNativeNeuralGateHistoricalMaterialIdentityManifest
    {
        try decodeCanonical(input, as: MaterialWire.self) {
            wire in
            try PrimeNativeNeuralGateHistoricalMaterialIdentityManifest(
                invocationRole: wire.invocationRole,
                sourceBytesResolved:
                    try observationState(
                        wire.sourceBytesResolved
                    ),
                adaptationProofRecomputed:
                    try observationState(
                        wire.adaptationProofRecomputed
                    )
            )
        }
    }

    static func decodeInvariant(
        input:
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput
    ) throws
        -> PrimeNativeNeuralGateHistoricalInvariantObservation
    {
        try decodeCanonical(input, as: InvariantWire.self) {
            wire in
            try PrimeNativeNeuralGateHistoricalInvariantObservation(
                invocationRole: wire.invocationRole,
                manifest: wire.manifest,
                globalStream: try reference(wire.globalStream),
                orderedChunks: try wire.orderedChunks.map(reference),
                recordsObserved:
                    try observationState(wire.recordsObserved),
                completeHistoricalRecordSetObserved:
                    try observationState(
                        wire.completeHistoricalRecordSetObserved
                    )
            )
        }
    }

    static func decodeFingerprint(
        input:
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput
    ) throws
        -> PrimeNativeNeuralGateHistoricalFingerprintObservation
    {
        try decodeCanonical(input, as: FingerprintWire.self) {
            wire in
            try PrimeNativeNeuralGateHistoricalFingerprintObservation(
                invocationRole: wire.invocationRole,
                observation: wire.observation,
                directRecomputationObserved:
                    try observationState(
                        wire.directRecomputationObserved
                    ),
                acceleratedRecomputationObserved:
                    try observationState(
                        wire.acceleratedRecomputationObserved
                    ),
                exactEqualityObserved:
                    try observationState(
                        wire.exactEqualityObserved
                    ),
                historicalSZRecomputed:
                    try observationState(
                        wire.historicalSZRecomputed
                    )
            )
        }
    }

    static func decodeMutations(
        input:
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput
    ) throws
        -> PrimeNativeNeuralGateHistoricalMutationSweepObservation
    {
        try decodeCanonical(input, as: MutationsWire.self) {
            wire in
            let observations = try wire.observations.map {
                value in
                try PrimeNativeNeuralGateHistoricalMutationRecordObservation(
                    ordinal: value.ordinal,
                    mutationID: value.mutationID,
                    allowedFailedLegIDs:
                        value.allowedFailedLegIDs,
                    observedFailedLegIDs:
                        value.observedFailedLegIDs,
                    baselineStreamSHA256:
                        value.baselineStreamSHA256,
                    mutatedStreamSHA256:
                        value.mutatedStreamSHA256,
                    restoredStreamSHA256:
                        value.restoredStreamSHA256,
                    baselineFingerprint:
                        value.baselineFingerprint,
                    mutatedFingerprint:
                        value.mutatedFingerprint,
                    restoredFingerprint:
                        value.restoredFingerprint,
                    mutationExecutionObserved:
                        try observationState(
                            value.mutationExecutionObserved
                        ),
                    independentDetectionObserved:
                        try observationState(
                            value.independentDetectionObserved
                        )
                )
            }
            return try
                PrimeNativeNeuralGateHistoricalMutationSweepObservation(
                    invocationRole: wire.invocationRole,
                    observations: observations,
                    exactCatalogCoverageObserved:
                        try observationState(
                            wire.exactCatalogCoverageObserved
                        ),
                    exactFailureSetsObserved:
                        try observationState(
                            wire.exactFailureSetsObserved
                        )
                )
        }
    }

    static func decodeGate(
        input:
            PrimeNativeNeuralGateHistoricalSemanticArtifactInput
    ) throws -> PrimeNativeNeuralGateHistoricalGateObservation {
        try decodeCanonical(input, as: GateWire.self) {
            wire in
            let legs = try wire.criticalLegs.map { value in
                try PrimeNativeNeuralGateSemanticCriticalLegObservation(
                    ordinal: value.ordinal,
                    legID: value.legID,
                    passed: try observationState(value.passed),
                    detail: value.detail,
                    evidence: try value.evidence.map(reference)
                )
            }
            return try PrimeNativeNeuralGateHistoricalGateObservation(
                invocationRole: wire.invocationRole,
                materialIdentity:
                    try reference(wire.materialIdentity),
                invariantManifest:
                    try reference(wire.invariantManifest),
                fingerprintObservation:
                    try reference(wire.fingerprintObservation),
                mutationObservation:
                    try reference(wire.mutationObservation),
                statisticsVerdictObservation:
                    try reference(
                        wire.statisticsVerdictObservation
                    ),
                criticalLegs: legs,
                sourceBoundCriticalLegEvidence:
                    try observationState(
                        wire.sourceBoundCriticalLegEvidence
                    ),
                modelExecutionObserved:
                    try observationState(
                        wire.modelExecutionObserved
                    )
            )
        }
    }

    static func reference(
        _ wire: ReferenceWire
    ) throws -> PrimeNativeNeuralGateSemanticArtifactReference {
        try PrimeNativeNeuralGateSemanticArtifactReference(
            schemaID: wire.schemaID,
            relativePath: wire.relativePath,
            contentSHA256: wire.contentSHA256,
            byteCount: wire.byteCount,
            maximumByteCount: wire.maximumByteCount,
            descriptorContentVerified:
                try observationState(
                    wire.descriptorContentVerified
                ),
            durablePublicationObserved:
                try observationState(
                    wire.durablePublicationObserved
                )
        )
    }

    static func observationState(
        _ rawValue: String
    ) throws -> PrimeNativeNeuralGateSemanticObservationState {
        switch rawValue {
        case "unavailable":
            return .unavailable
        case "observed_false":
            return .observedFalse
        case "observed_true":
            return .observedTrue
        default:
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidSemanticLeaf("observation_state")
        }
    }

    static func validateCrossLeafJoins(
        _ value:
            PrimeNativeNeuralGateHistoricalDecodedCanonicalLeaves
    ) throws {
        let role = value.invocationRole
        let namespace =
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1
        try namespace.validate()
        let invariant = value.invariantManifest
        let manifest = invariant.manifest
        let baselineFingerprint =
            value.fingerprint.observation.direct
        let baselineStreamSHA256 =
            manifest.globalStreamSHA256
        let fingerprintIsInField: (
            PrimeNativeNeuralGateFingerprint
        ) -> Bool = { fingerprint in
            fingerprint.recordCount == manifest.recordCount
                && fingerprint.residues.allSatisfy {
                    $0 < fingerprint.prime
                }
        }

        guard value.materialIdentity.invocationRole == role,
              value.gate.invocationRole == role,
              invariant.invocationRole == role,
              value.fingerprint.invocationRole == role,
              value.mutations.invocationRole == role,
              value.statistics.invocationRole == role,
              manifest.recordCount
                == namespace.exactInvariantRecordCount,
              manifest.chunks.count
                == namespace.exactInvariantChunkCount,
              manifest.chunks.map(\.ordinal)
                == (0 ..< namespace.exactInvariantChunkCount)
                .map(UInt32.init),
              try manifest.chunks.allSatisfy({ chunk in
                  chunk.recordCount
                    == (try namespace.invariantRecordCount(
                        forChunkOrdinal: chunk.ordinal
                    ))
              }),
              invariant.recordsObserved == .unavailable,
              invariant.completeHistoricalRecordSetObserved
                == .unavailable,
              !invariant.durablePublicationObserved,
              value.fingerprint
                .directRecomputationObserved == .unavailable,
              value.fingerprint
                .acceleratedRecomputationObserved == .unavailable,
              value.fingerprint.exactEqualityObserved
                == .unavailable,
              value.fingerprint.historicalSZRecomputed
                == .unavailable,
              !value.fingerprint.mechanicsPassAuthorized,
              value.fingerprint.observation
                == PrimeNativeNeuralGateFingerprintObservation(
                    orderedMultisetStreamSHA256:
                        baselineStreamSHA256,
                    direct: baselineFingerprint,
                    accelerated: baselineFingerprint
                ),
              fingerprintIsInField(baselineFingerprint),
              value.mutations.exactCatalogCoverageObserved
                == .unavailable,
              value.mutations.exactFailureSetsObserved
                == .unavailable,
              !value.mutations.executionImplementedHere,
              !value.mutations.mechanicsPassAuthorized,
              value.mutations.observations.allSatisfy({ row in
                  row.allowedFailedLegIDs
                    == [row.expectedFailedLegID]
                      && row.observedFailedLegIDs
                        == [row.expectedFailedLegID]
                      && row.baselineStreamSHA256
                        == baselineStreamSHA256
                      && row.restoredStreamSHA256
                        == baselineStreamSHA256
                      && row.baselineFingerprint
                        == baselineFingerprint
                      && row.restoredFingerprint
                        == baselineFingerprint
                      && fingerprintIsInField(
                        row.mutatedFingerprint
                      )
                      && row.mutationExecutionObserved
                        == .unavailable
                      && row.independentDetectionObserved
                        == .unavailable
              }),
              value.gate.sourceBoundCriticalLegEvidence
                == .unavailable,
              value.gate.modelExecutionObserved == .unavailable,
              value.gate.mechanicsOutcome == .abstain,
              !value.gate.mechanicsPassAuthorized,
              !value.gate.scientificAuthorityAuthorized,
              !value.gate.productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidArtifactSet("cross_leaf_semantics")
        }

        let expectedGlobal = try expectedReference(
            key: .invariantRecordsGlobal(role),
            byteCount: UInt64(manifest.globalStreamByteCount),
            sha256: manifest.globalStreamSHA256
        )
        let expectedChunks = try manifest.chunks.map { chunk in
            try expectedReference(
                key: .invariantChunk(role, chunk.ordinal),
                byteCount: UInt64(chunk.byteCount),
                sha256: chunk.sha256
            )
        }
        guard invariant.globalStream == expectedGlobal,
              invariant.orderedChunks == expectedChunks
        else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidArtifactSet("invariant_references")
        }

        let gateReferencePairs: [(
            PrimeNativeNeuralGateSemanticArtifactReference,
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
        )] = [
            (
                value.gate.materialIdentity,
                .materialIdentityManifest(role)
            ),
            (
                value.gate.invariantManifest,
                .invariantRecordsManifest(role)
            ),
            (
                value.gate.fingerprintObservation,
                .fingerprintObservation(role)
            ),
            (
                value.gate.mutationObservation,
                .mutationObservations(role)
            ),
            (
                value.gate.statisticsVerdictObservation,
                .statisticsVerdictObservation(role)
            ),
        ]
        for (reference, key) in gateReferencePairs {
            let bound = try value.binding(for: key)
            let expected = try expectedReference(
                key: key,
                byteCount: bound.byteCount,
                sha256: bound.sha256
            )
            guard reference == expected else {
                throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                    .invalidArtifactSet("gate_reference")
            }
        }

        let carriers =
            value.statistics.historicalCriticalLegValues
        let legs = value.gate.criticalLegs
        guard carriers.count == 10,
              legs.count == carriers.count,
              zip(carriers, legs).allSatisfy({ carrier, leg in
                  leg.ordinal == carrier.ordinal
                      && leg.legID == carrier.legID
                      && leg.passed == .unavailable
                      && leg.evidence.isEmpty
                      && leg.detail
                        == "source_derived_historical_carrier_passed_"
                            + (carrier.passed ? "true" : "false")
              })
        else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
                .invalidArtifactSet("critical_leg_join")
        }
    }

    static func expectedReference(
        key:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey,
        byteCount: UInt64,
        sha256: String
    ) throws -> PrimeNativeNeuralGateSemanticArtifactReference {
        let spec = try
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1.spec(for: key)
        return try PrimeNativeNeuralGateSemanticArtifactReference(
            schemaID: spec.schemaID,
            relativePath: spec.relativePath,
            contentSHA256: sha256,
            byteCount: byteCount,
            maximumByteCount: spec.maximumByteCount,
            descriptorContentVerified: .unavailable,
            durablePublicationObserved: .unavailable
        )
    }
}
