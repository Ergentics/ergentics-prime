import Foundation
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics

public struct PrimeNativeNeuralGateHistoricalSourcePin:
    Encodable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let roleID: String
    public let repositoryRelativePath: String
    public let gitBlobOID: String
    public let byteCount: UInt64
    public let sha256: String

    fileprivate init(
        ordinal: Int,
        roleID: String,
        repositoryRelativePath: String,
        gitBlobOID: String,
        byteCount: UInt64,
        sha256: String
    ) {
        self.ordinal = ordinal
        self.roleID = roleID
        self.repositoryRelativePath =
            repositoryRelativePath
        self.gitBlobOID = gitBlobOID
        self.byteCount = byteCount
        self.sha256 = sha256
    }

    public func validate() throws {
        guard ordinal > 0,
              semanticIsSafeIdentifier(roleID),
              semanticIsSafeRelativePath(
                  repositoryRelativePath
              ),
              gitBlobOID.utf8.count == 40,
              gitBlobOID.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                      || ($0 >= 97 && $0 <= 102)
              }),
              byteCount > 0,
              semanticIsLowercaseSHA256(sha256)
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidSourceIdentity(roleID)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case roleID = "role_id"
        case repositoryRelativePath =
            "repository_relative_path"
        case gitBlobOID = "git_blob_oid"
        case byteCount = "byte_count"
        case sha256
    }
}

public struct PrimeNativeNeuralGateHistoricalMaterialIdentityContract:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let replayPlanID: String
    public let replayPlanSHA256: String
    public let companionRemoteURL: String
    public let companionRevision: String
    public let companionTreeOID: String
    public let inputCatalogID: String
    public let inputCatalogSHA256: String
    public let exactInputCount: Int
    public let exactTotalInputByteCount: UInt64
    public let sourcePins:
        [PrimeNativeNeuralGateHistoricalSourcePin]
    public let sourceBytesResolvedHere: Bool
    public let donorBytesExecutedHere: Bool
    public let historicalEvidenceReconstructed:
        Bool

    public static let frozenV1 = Self(
        schemaVersion: 1,
        contractID:
            "prime_stage_b_historical_material_identity_contract_v1",
        replayPlanID:
            "ergentics_prime_native_neural_gate_dual_fixture_replay_v5",
        replayPlanSHA256:
            "c811555bc3a04f053378519ca9c33d18de075d0eb7b347587a9789f4aff3466b",
        companionRemoteURL:
            "https://github.com/Ergentics/pmhnp-companion-ergentics.git",
        companionRevision:
            "163fc100710ece48119bc25954452d10f6a84f7f",
        companionTreeOID:
            "9009daa4f8a07fbd5897e00b9571cef44ec292db",
        inputCatalogID:
            "prime_stage_b_exact_eleven_source_input_catalog_v1",
        inputCatalogSHA256:
            "e9ac9a697dd24cbe6583c713e96840c810cda1771497a6a69ace1e190963bca4",
        exactInputCount: 11,
        exactTotalInputByteCount: 1_232_537,
        sourcePins: makeHistoricalSourcePins(),
        sourceBytesResolvedHere: false,
        donorBytesExecutedHere: false,
        historicalEvidenceReconstructed: false
    )

    public func validate() throws {
        try sourcePins.forEach { try $0.validate() }
        guard self == .frozenV1,
              schemaVersion == 1,
              exactInputCount == 11,
              sourcePins.count == exactInputCount,
              sourcePins.map(\.ordinal)
                == Array(1 ... exactInputCount),
              Set(sourcePins.map(\.roleID)).count
                == exactInputCount,
              sourcePins.map(\.byteCount).reduce(0, +)
                == exactTotalInputByteCount,
              semanticIsLowercaseSHA256(
                  replayPlanSHA256
              ),
              semanticIsLowercaseSHA256(
                  inputCatalogSHA256
              ),
              companionRevision.utf8.count == 40,
              companionTreeOID.utf8.count == 40,
              !sourceBytesResolvedHere,
              !donorBytesExecutedHere,
              !historicalEvidenceReconstructed
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidFrozenContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case replayPlanID = "replay_plan_id"
        case replayPlanSHA256 = "replay_plan_sha256"
        case companionRemoteURL = "companion_remote_url"
        case companionRevision = "companion_revision"
        case companionTreeOID = "companion_tree_oid"
        case inputCatalogID = "input_catalog_id"
        case inputCatalogSHA256 = "input_catalog_sha256"
        case exactInputCount = "exact_input_count"
        case exactTotalInputByteCount =
            "exact_total_input_byte_count"
        case sourcePins = "source_pins"
        case sourceBytesResolvedHere =
            "source_bytes_resolved_here"
        case donorBytesExecutedHere =
            "donor_bytes_executed_here"
        case historicalEvidenceReconstructed =
            "historical_evidence_reconstructed"
    }
}

public struct PrimeNativeNeuralGateHistoricalMaterialIdentityManifest:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalArtifactRole
    public let materialIdentityContractID: String
    public let inputCatalogSHA256: String
    public let boundSourcePins:
        [PrimeNativeNeuralGateHistoricalSourcePin]
    public let sourceBytesResolved:
        PrimeNativeNeuralGateSemanticObservationState
    public let adaptationProofRecomputed:
        PrimeNativeNeuralGateSemanticObservationState
    public let donorBytesExecuted: Bool
    public let mechanicsPassAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    public init(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole,
        sourceBytesResolved:
            PrimeNativeNeuralGateSemanticObservationState,
        adaptationProofRecomputed:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        let contract =
            PrimeNativeNeuralGateHistoricalMaterialIdentityContract
            .frozenV1
        schemaVersion = 1
        schemaID =
            "prime_stage_b_historical_material_identity_manifest_v1"
        self.invocationRole = invocationRole
        materialIdentityContractID = contract.contractID
        inputCatalogSHA256 = contract.inputCatalogSHA256
        boundSourcePins = contract.sourcePins
        self.sourceBytesResolved = sourceBytesResolved
        self.adaptationProofRecomputed =
            adaptationProofRecomputed
        donorBytesExecuted = false
        mechanicsPassAuthorized = false
        scientificAuthorityAuthorized = false
        productAuthorityAuthorized = false
        try validate()
    }

    public var relativePath: String {
        historicalRolePrefix(invocationRole)
            + "/material-identity-manifest.v1.json"
    }

    public func validate() throws {
        let contract =
            PrimeNativeNeuralGateHistoricalMaterialIdentityContract
            .frozenV1
        try contract.validate()
        guard schemaVersion == 1,
              semanticIsSafeIdentifier(schemaID),
              materialIdentityContractID
                == contract.contractID,
              inputCatalogSHA256
                == contract.inputCatalogSHA256,
              boundSourcePins == contract.sourcePins,
              semanticIsSafeRelativePath(relativePath),
              !donorBytesExecuted,
              !mechanicsPassAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidHistoricalObservation(
                    "material_identity"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case invocationRole = "invocation_role"
        case materialIdentityContractID =
            "material_identity_contract_id"
        case inputCatalogSHA256 = "input_catalog_sha256"
        case boundSourcePins = "bound_source_pins"
        case sourceBytesResolved = "source_bytes_resolved"
        case adaptationProofRecomputed =
            "adaptation_proof_recomputed"
        case donorBytesExecuted = "donor_bytes_executed"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
    }
}

public struct PrimeNativeNeuralGateHistoricalInvariantObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalArtifactRole
    public let manifest:
        PrimeNativeNeuralGateInvariantManifest
    public let globalStream:
        PrimeNativeNeuralGateSemanticArtifactReference
    public let orderedChunks:
        [PrimeNativeNeuralGateSemanticArtifactReference]
    public let recordsObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let completeHistoricalRecordSetObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let durablePublicationObserved: Bool

    public init(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole,
        manifest:
            PrimeNativeNeuralGateInvariantManifest,
        globalStream:
            PrimeNativeNeuralGateSemanticArtifactReference,
        orderedChunks:
            [PrimeNativeNeuralGateSemanticArtifactReference],
        recordsObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        completeHistoricalRecordSetObserved:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        schemaVersion = 1
        schemaID =
            "prime_stage_b_historical_invariant_observation_v1"
        self.invocationRole = invocationRole
        self.manifest = manifest
        self.globalStream = globalStream
        self.orderedChunks = orderedChunks
        self.recordsObserved = recordsObserved
        self.completeHistoricalRecordSetObserved =
            completeHistoricalRecordSetObserved
        durablePublicationObserved = false
        try validate()
    }

    public func validate() throws {
        try globalStream.validate()
        try orderedChunks.forEach { try $0.validate() }
        let prefix = historicalRolePrefix(invocationRole)
        let chunks = manifest.chunks
        guard schemaVersion == 1,
              manifest.schemaVersion == 1,
              manifest.artifactKind
                == "ergentics_prime_native_neural_gate_invariant_manifest",
              manifest.serializationContractID
                == PrimeNativeNeuralGateInvariantCodec
                .serializationContractID,
              manifest.recordCount > 0,
              manifest.recordCount
                <= PrimeNativeNeuralGateReplayDecodeLimits
                .stageB.maximumRecordCount,
              manifest.globalStreamByteCount > 0,
              manifest.globalStreamByteCount
                <= PrimeNativeNeuralGateReplayDecodeLimits
                .stageB.maximumAggregateRecordBytes,
              semanticIsLowercaseSHA256(
                  manifest.globalStreamSHA256
              ),
              globalStream.relativePath
                == prefix + "/invariant-records.v1.bin",
              globalStream.contentSHA256
                == manifest.globalStreamSHA256,
              globalStream.byteCount
                == UInt64(manifest.globalStreamByteCount),
              chunks.count == orderedChunks.count,
              chunks.map(\.ordinal)
                == chunks.indices.map(UInt32.init),
              chunks.allSatisfy({
                  $0.recordCount > 0
                      && $0.recordCount
                        <= PrimeNativeNeuralGateInvariantCodec
                        .maximumRecordsPerChunk
                      && $0.byteCount > 0
                      && semanticIsLowercaseSHA256($0.sha256)
              }),
              chunks.map(\.recordCount).reduce(0, +)
                == manifest.recordCount,
              zip(chunks, orderedChunks).allSatisfy({
                  $0.1.relativePath
                    == prefix
                        + "/invariant-chunks/"
                        + String(
                            format: "%08d",
                            $0.0.ordinal
                        )
                        + ".v1.bin"
                      && $0.1.contentSHA256 == $0.0.sha256
                      && $0.1.byteCount
                        == UInt64($0.0.byteCount)
              }),
              !durablePublicationObserved
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidHistoricalObservation("invariants")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case invocationRole = "invocation_role"
        case manifest
        case globalStream = "global_stream"
        case orderedChunks = "ordered_chunks"
        case recordsObserved = "records_observed"
        case completeHistoricalRecordSetObserved =
            "complete_historical_record_set_observed"
        case durablePublicationObserved =
            "durable_publication_observed"
    }
}

public struct PrimeNativeNeuralGateHistoricalFingerprintObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalArtifactRole
    public let observation:
        PrimeNativeNeuralGateFingerprintObservation
    public let directRecomputationObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let acceleratedRecomputationObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let exactEqualityObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let historicalSZRecomputed:
        PrimeNativeNeuralGateSemanticObservationState
    public let mechanicsPassAuthorized: Bool

    public init(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole,
        observation:
            PrimeNativeNeuralGateFingerprintObservation,
        directRecomputationObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        acceleratedRecomputationObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        exactEqualityObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        historicalSZRecomputed:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        schemaVersion = 1
        schemaID =
            "prime_stage_b_historical_fingerprint_observation_v1"
        self.invocationRole = invocationRole
        self.observation = observation
        self.directRecomputationObserved =
            directRecomputationObserved
        self.acceleratedRecomputationObserved =
            acceleratedRecomputationObserved
        self.exactEqualityObserved =
            exactEqualityObserved
        self.historicalSZRecomputed =
            historicalSZRecomputed
        mechanicsPassAuthorized = false
        try validate()
    }

    public func validate() throws {
        let direct = observation.direct
        guard schemaVersion == 1,
              observation.schemaVersion == 1,
              observation.artifactKind
                == "ergentics_prime_native_neural_gate_fingerprint_observation",
              observation.directAlgorithmID
                == PrimeNativeNeuralGateFingerprintMechanics
                .directAlgorithmID,
              observation.acceleratedAlgorithmID
                == PrimeNativeNeuralGateFingerprintMechanics
                .acceleratedAlgorithmID,
              semanticIsLowercaseSHA256(
                  observation.orderedMultisetStreamSHA256
              ),
              direct.prime
                == PrimeNativeNeuralGateFingerprintMechanics
                .prime,
              direct.evaluationPoints
                == PrimeNativeNeuralGateFingerprintMechanics
                .evaluationPoints,
              direct.residues.count
                == direct.evaluationPoints.count,
              direct.recordCount > 0,
              direct.recordCount
                <= PrimeNativeNeuralGateReplayDecodeLimits
                .stageB.maximumRecordCount,
              observation.exactEqualityObserved
                == (observation.direct
                    == observation.accelerated),
              observation.cacheKey
                == PrimeNativeNeuralGateFingerprintMechanics
                .cacheKey(
                    streamSHA256:
                        observation
                        .orderedMultisetStreamSHA256
                ),
              !mechanicsPassAuthorized
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidHistoricalObservation("fingerprint")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
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
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
    }
}

/// Historical 46-case observation record. This is a data schema only; it
/// contains no mutation transform and no detector implementation.
public struct PrimeNativeNeuralGateHistoricalMutationRecordObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let ordinal: UInt32
    public let mutationID: String
    public let expectedFailedLegID: String
    public let allowedFailedLegIDs: [String]
    public let observedFailedLegIDs: [String]
    public let baselineStreamSHA256: String
    public let mutatedStreamSHA256: String
    public let restoredStreamSHA256: String
    public let baselineFingerprint:
        PrimeNativeNeuralGateFingerprint
    public let mutatedFingerprint:
        PrimeNativeNeuralGateFingerprint
    public let restoredFingerprint:
        PrimeNativeNeuralGateFingerprint
    public let mutationExecutionObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let independentDetectionObserved:
        PrimeNativeNeuralGateSemanticObservationState

    public init(
        ordinal: UInt32,
        mutationID: String,
        allowedFailedLegIDs: [String],
        observedFailedLegIDs: [String],
        baselineStreamSHA256: String,
        mutatedStreamSHA256: String,
        restoredStreamSHA256: String,
        baselineFingerprint:
            PrimeNativeNeuralGateFingerprint,
        mutatedFingerprint:
            PrimeNativeNeuralGateFingerprint,
        restoredFingerprint:
            PrimeNativeNeuralGateFingerprint,
        mutationExecutionObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        independentDetectionObserved:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        let catalog =
            PrimeNativeNeuralGateMutationCatalog
            .historicalEntries
        guard ordinal > 0,
              Int(ordinal) <= catalog.count
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidHistoricalObservation("mutation_ordinal")
        }
        let entry = catalog[Int(ordinal - 1)]
        self.ordinal = ordinal
        self.mutationID = mutationID
        expectedFailedLegID = entry.expectedFailedLegID
        self.allowedFailedLegIDs = allowedFailedLegIDs
        self.observedFailedLegIDs = observedFailedLegIDs
        self.baselineStreamSHA256 = baselineStreamSHA256
        self.mutatedStreamSHA256 = mutatedStreamSHA256
        self.restoredStreamSHA256 = restoredStreamSHA256
        self.baselineFingerprint = baselineFingerprint
        self.mutatedFingerprint = mutatedFingerprint
        self.restoredFingerprint = restoredFingerprint
        self.mutationExecutionObserved =
            mutationExecutionObserved
        self.independentDetectionObserved =
            independentDetectionObserved
        try validate()
    }

    public func validate() throws {
        let catalog =
            PrimeNativeNeuralGateMutationCatalog
            .historicalEntries
        guard ordinal > 0,
              Int(ordinal) <= catalog.count
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidHistoricalObservation("mutation_ordinal")
        }
        let entry = catalog[Int(ordinal - 1)]
        let fingerprints = [
            baselineFingerprint,
            mutatedFingerprint,
            restoredFingerprint,
        ]
        guard mutationID == entry.mutationID,
              expectedFailedLegID
                == entry.expectedFailedLegID,
              !allowedFailedLegIDs.isEmpty,
              allowedFailedLegIDs.contains(
                  expectedFailedLegID
              ),
              Set(allowedFailedLegIDs).count
                == allowedFailedLegIDs.count,
              Set(observedFailedLegIDs).count
                == observedFailedLegIDs.count,
              observedFailedLegIDs.allSatisfy({
                  PrimeNativeNeuralGateReplayLegDomain
                    .historicalCriticalLegIDs.contains($0)
              }),
              [
                  baselineStreamSHA256,
                  mutatedStreamSHA256,
                  restoredStreamSHA256,
              ].allSatisfy(semanticIsLowercaseSHA256),
              fingerprints.allSatisfy({
                  $0.prime
                    == PrimeNativeNeuralGateFingerprintMechanics
                    .prime
                      && $0.evaluationPoints
                        == PrimeNativeNeuralGateFingerprintMechanics
                        .evaluationPoints
                      && $0.residues.count == 3
                      && $0.recordCount > 0
              })
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidHistoricalObservation(mutationID)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case mutationID = "mutation_id"
        case expectedFailedLegID =
            "expected_failed_leg_id"
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

public struct PrimeNativeNeuralGateHistoricalMutationSweepObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalArtifactRole
    public let catalogID: String
    public let catalogSHA256: String
    public let observations:
        [PrimeNativeNeuralGateHistoricalMutationRecordObservation]
    public let exactCatalogCoverageObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let exactFailureSetsObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let executionImplementedHere: Bool
    public let mechanicsPassAuthorized: Bool

    public init(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole,
        observations:
            [PrimeNativeNeuralGateHistoricalMutationRecordObservation],
        exactCatalogCoverageObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        exactFailureSetsObserved:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        schemaVersion = 1
        schemaID =
            "prime_stage_b_historical_mutation_observation_v1"
        self.invocationRole = invocationRole
        catalogID =
            "prime_stage_b_historical_forensic_mutation_catalog_46_v1"
        catalogSHA256 =
            "8a1f70ae9f20f60e63cc53df6841d8a160bcbee61621c6f80a4f0272a186100f"
        self.observations = observations
        self.exactCatalogCoverageObserved =
            exactCatalogCoverageObserved
        self.exactFailureSetsObserved =
            exactFailureSetsObserved
        executionImplementedHere = false
        mechanicsPassAuthorized = false
        try validate()
    }

    public func validate() throws {
        try observations.forEach { try $0.validate() }
        let expected =
            PrimeNativeNeuralGateMutationCatalog
            .historicalEntries
        guard schemaVersion == 1,
              observations.count == 46,
              observations.map(\.ordinal)
                == expected.map(\.ordinal),
              observations.map(\.mutationID)
                == expected.map(\.mutationID),
              observations.map(\.expectedFailedLegID)
                == expected.map(\.expectedFailedLegID),
              !executionImplementedHere,
              !mechanicsPassAuthorized
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidHistoricalObservation("mutation_sweep")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case invocationRole = "invocation_role"
        case catalogID = "catalog_id"
        case catalogSHA256 = "catalog_sha256"
        case observations
        case exactCatalogCoverageObserved =
            "exact_catalog_coverage_observed"
        case exactFailureSetsObserved =
            "exact_failure_sets_observed"
        case executionImplementedHere =
            "execution_implemented_here"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
    }
}

public struct PrimeNativeNeuralGateHistoricalGateObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalArtifactRole
    public let materialIdentity:
        PrimeNativeNeuralGateSemanticArtifactReference
    public let invariantManifest:
        PrimeNativeNeuralGateSemanticArtifactReference
    public let fingerprintObservation:
        PrimeNativeNeuralGateSemanticArtifactReference
    public let mutationObservation:
        PrimeNativeNeuralGateSemanticArtifactReference
    public let statisticsVerdictObservation:
        PrimeNativeNeuralGateSemanticArtifactReference
    public let criticalLegs:
        [PrimeNativeNeuralGateSemanticCriticalLegObservation]
    public let mechanicsOutcome:
        PrimeNativeNeuralGateSemanticMechanicsOutcome
    public let sourceBoundCriticalLegEvidence:
        PrimeNativeNeuralGateSemanticObservationState
    public let modelExecutionObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let mechanicsPassAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    public init(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole,
        materialIdentity:
            PrimeNativeNeuralGateSemanticArtifactReference,
        invariantManifest:
            PrimeNativeNeuralGateSemanticArtifactReference,
        fingerprintObservation:
            PrimeNativeNeuralGateSemanticArtifactReference,
        mutationObservation:
            PrimeNativeNeuralGateSemanticArtifactReference,
        statisticsVerdictObservation:
            PrimeNativeNeuralGateSemanticArtifactReference,
        criticalLegs:
            [PrimeNativeNeuralGateSemanticCriticalLegObservation],
        sourceBoundCriticalLegEvidence:
            PrimeNativeNeuralGateSemanticObservationState,
        modelExecutionObserved:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        schemaVersion = 1
        schemaID =
            "prime_stage_b_historical_gate_observation_v1"
        self.invocationRole = invocationRole
        self.materialIdentity = materialIdentity
        self.invariantManifest = invariantManifest
        self.fingerprintObservation =
            fingerprintObservation
        self.mutationObservation = mutationObservation
        self.statisticsVerdictObservation =
            statisticsVerdictObservation
        self.criticalLegs = criticalLegs
        self.sourceBoundCriticalLegEvidence =
            sourceBoundCriticalLegEvidence
        self.modelExecutionObserved =
            modelExecutionObserved
        mechanicsOutcome = Self.deriveMechanicsOutcome(
            aggregateReferences: [
                materialIdentity,
                invariantManifest,
                fingerprintObservation,
                mutationObservation,
                statisticsVerdictObservation,
            ],
            criticalLegs: criticalLegs,
            sourceBoundCriticalLegEvidence:
                sourceBoundCriticalLegEvidence,
            modelExecutionObserved: modelExecutionObserved
        )
        mechanicsPassAuthorized = false
        scientificAuthorityAuthorized = false
        productAuthorityAuthorized = false
        try validate()
    }

    public func validate() throws {
        try [
            materialIdentity,
            invariantManifest,
            fingerprintObservation,
            mutationObservation,
            statisticsVerdictObservation,
        ].forEach { try $0.validate() }
        try criticalLegs.forEach { try $0.validate() }
        let prefix = historicalRolePrefix(invocationRole)
        let aggregateReferences = [
            materialIdentity,
            invariantManifest,
            fingerprintObservation,
            mutationObservation,
            statisticsVerdictObservation,
        ]
        let allCriticalLegEvidenceIsBound =
            semanticAllCriticalLegEvidenceIsFullyBound(
                criticalLegs
            )
        let expectedOutcome = Self.deriveMechanicsOutcome(
            aggregateReferences: aggregateReferences,
            criticalLegs: criticalLegs,
            sourceBoundCriticalLegEvidence:
                sourceBoundCriticalLegEvidence,
            modelExecutionObserved: modelExecutionObserved
        )
        guard schemaVersion == 1,
              criticalLegs.count == 10,
              criticalLegs.map(\.legID)
                == PrimeNativeNeuralGateSemanticVerdictPolicy
                .orderedCriticalLegIDs,
              materialIdentity.relativePath
                == prefix
                    + "/material-identity-manifest.v1.json",
              invariantManifest.relativePath
                == prefix
                    + "/invariant-records-manifest.v1.json",
              fingerprintObservation.relativePath
                == prefix
                    + "/fingerprint-observation.v1.json",
              mutationObservation.relativePath
                == prefix
                    + "/mutation-observations.v1.json",
              statisticsVerdictObservation.relativePath
                == prefix
                    + "/statistics-verdict-observation.v1.json",
              sourceBoundCriticalLegEvidence != .observedTrue
                || allCriticalLegEvidenceIsBound,
              mechanicsOutcome == expectedOutcome,
              !mechanicsPassAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidHistoricalObservation("gate")
        }
    }

    private static func deriveMechanicsOutcome(
        aggregateReferences:
            [PrimeNativeNeuralGateSemanticArtifactReference],
        criticalLegs:
            [PrimeNativeNeuralGateSemanticCriticalLegObservation],
        sourceBoundCriticalLegEvidence:
            PrimeNativeNeuralGateSemanticObservationState,
        modelExecutionObserved:
            PrimeNativeNeuralGateSemanticObservationState
    ) -> PrimeNativeNeuralGateSemanticMechanicsOutcome {
        let allTenCriticalLegsObservedTrue =
            criticalLegs.count
                == PrimeNativeNeuralGateSemanticVerdictPolicy
                .orderedCriticalLegIDs.count
            && criticalLegs.allSatisfy {
                $0.passed == .observedTrue
            }
        guard allTenCriticalLegsObservedTrue,
              semanticAllCriticalLegEvidenceIsFullyBound(
                  criticalLegs
              ),
              aggregateReferences.count == 5,
              aggregateReferences.allSatisfy(
                  semanticArtifactReferenceIsVerifiedAndDurablyPublished
              ),
              sourceBoundCriticalLegEvidence == .observedTrue,
              modelExecutionObserved == .observedTrue
        else {
            return .abstain
        }
        return .grounded
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case invocationRole = "invocation_role"
        case materialIdentity = "material_identity"
        case invariantManifest = "invariant_manifest"
        case fingerprintObservation =
            "fingerprint_observation"
        case mutationObservation = "mutation_observation"
        case statisticsVerdictObservation =
            "statistics_verdict_observation"
        case criticalLegs = "critical_legs"
        case mechanicsOutcome = "mechanics_outcome"
        case sourceBoundCriticalLegEvidence =
            "source_bound_critical_leg_evidence"
        case modelExecutionObserved =
            "model_execution_observed"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
    }
}

public struct
    PrimeNativeNeuralGateHistoricalStatisticsVerdictObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalArtifactRole
    public let observation:
        PrimeNativeNeuralGateStatisticsVerdictObservation
    public let historicalSummaryRecordCount: Int
    public let historicalSummaryMaySupplyEvidence:
        Bool

    public init(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole,
        observation:
            PrimeNativeNeuralGateStatisticsVerdictObservation
    ) throws {
        schemaVersion = 1
        schemaID =
            "prime_stage_b_historical_statistics_verdict_observation_v1"
        self.invocationRole = invocationRole
        self.observation = observation
        historicalSummaryRecordCount = 59_497
        historicalSummaryMaySupplyEvidence = false
        try validate()
    }

    public func validate() throws {
        try observation.validate()
        guard schemaVersion == 1,
              observation.arm == .historicalForensic,
              historicalSummaryRecordCount == 59_497,
              !historicalSummaryMaySupplyEvidence
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidHistoricalObservation(
                    "statistics_verdict"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case invocationRole = "invocation_role"
        case observation
        case historicalSummaryRecordCount =
            "historical_summary_record_count"
        case historicalSummaryMaySupplyEvidence =
            "historical_summary_may_supply_evidence"
    }
}

func historicalRolePrefix(
    _ role: PrimeNativeNeuralGateHistoricalArtifactRole
) -> String {
    "neural-gate-replay/historical/\(role.rawValue)"
}

private func makeHistoricalSourcePins()
    -> [PrimeNativeNeuralGateHistoricalSourcePin]
{
    func pin(
        _ ordinal: Int,
        _ role: String,
        _ path: String,
        _ blob: String,
        _ bytes: UInt64,
        _ sha256: String
    ) -> PrimeNativeNeuralGateHistoricalSourcePin {
        .init(
            ordinal: ordinal,
            roleID: role,
            repositoryRelativePath: path,
            gitBlobOID: blob,
            byteCount: bytes,
            sha256: sha256
        )
    }
    return [
        pin(
            1,
            "native_language_gate",
            "neural-kit/Sources/NeuralKit/PrimeNeuralNativeLanguageVerifyAbstainGate.swift",
            "795fff7c458ec68ba4562b6cd1c674fe8de7ffc4",
            368_918,
            "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6"
        ),
        pin(
            2,
            "native_byte_tokenizer_authority",
            "prime-runtime/Sources/ErgenticsPrimeRuntime/PrimeNativeByteTokenizer.swift",
            "27f5d4f61864499027d3e65516ae4c5cfe1ff5d1",
            21_320,
            "9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721"
        ),
        pin(
            3,
            "native_text_corpus_authority",
            "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift",
            "b2a087c9410a71f2bc99debade752ff779d7a8a8",
            177_032,
            "4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210"
        ),
        pin(
            4,
            "canary_report_authority",
            "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift",
            "027a25b49dde1acfb4cd8af970e05ecd8241f427",
            216_815,
            "8706343bf93c1dac70f5c263f7111667574da751cd27d6c3321a92fd822f063f"
        ),
        pin(
            5,
            "run_configuration_authority",
            "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageRunConfiguration.swift",
            "d9141e1c08263f10f06b68acada836dc59a45dc9",
            18_069,
            "1f770ed0a044597f6efd7ce1d74e14763cc5e64eeaa0e4036001a311d9e41c7b"
        ),
        pin(
            6,
            "artifact_path_safety_authority",
            "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageArtifactPathSafety.swift",
            "f7404c905c58e8ff2d51f90ee90dad6cb61cbedc",
            51_514,
            "cfeb5d3e3d3a39001f569239f5f9f4c1cb1c669342b366b12930793d36826f7c"
        ),
        pin(
            7,
            "profile_trial_failure_authority",
            "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageProfileTrialFailure.swift",
            "ed64476a8aea3010fe4e6a8b4f799eeb58e64d34",
            16_567,
            "42d022ad2f9c423c9d1ff9e7fc52fc6576a51320a972c738d9d98fd84a956463"
        ),
        pin(
            8,
            "scale_recommendation_lineage",
            "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeScaleEngineRecommend.swift",
            "c3f1e242d07ad3cc7b8e961edab868a895d567df",
            190_002,
            "7cdc5ec341d7527c873b458c2ccb24ca27f9104709e9c37066d755bbb951a7ea"
        ),
        pin(
            9,
            "verdict_carrier",
            "neural-kit/Sources/NeuralKit/PrimeNeuralVerifyAbstainGate.swift",
            "3866cc1fd1b39829c913376abece2454b0c11624",
            4_659,
            "7f5ee1ee5579d13cec0ea4802994e6f07c4117c8202714f40fe1e3a0de21a42c"
        ),
        pin(
            10,
            "behavioral_regression_fixture",
            "neural-kit/Tests/NeuralKitTests/EngineProposesNativeLanguageVerifyAbstainTests.swift",
            "aa87aff21832ebd5c7a6598692139b81ae065e0b",
            165_692,
            "266475d337fb49ba9c84e03a53871269a73812c3200a830a799ef90f4901968c"
        ),
        pin(
            11,
            "neural_kit_package_lock",
            "neural-kit/Package.resolved",
            "18aef69512c82c3e6cdff192f3aa0a6ee13c702e",
            1_949,
            "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
        ),
    ]
}
