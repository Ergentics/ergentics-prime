// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

/// Additive keys for the complete historical semantic artifact set.
///
/// These keys do not amend the frozen V4 namespace. They provide a separate,
/// non-authorizing overlay for a later historical-only projection codec.
public enum PrimeNativeNeuralGateHistoricalSemanticArtifactKey:
    Equatable,
    Hashable,
    Sendable
{
    case materialIdentityManifest(
        PrimeNativeNeuralGateHistoricalArtifactRole
    )
    case gateObservation(
        PrimeNativeNeuralGateHistoricalArtifactRole
    )
    case invariantRecordsManifest(
        PrimeNativeNeuralGateHistoricalArtifactRole
    )
    case invariantRecordsGlobal(
        PrimeNativeNeuralGateHistoricalArtifactRole
    )
    case fingerprintObservation(
        PrimeNativeNeuralGateHistoricalArtifactRole
    )
    case mutationObservations(
        PrimeNativeNeuralGateHistoricalArtifactRole
    )
    case statisticsVerdictObservation(
        PrimeNativeNeuralGateHistoricalArtifactRole
    )
    case invariantChunk(
        PrimeNativeNeuralGateHistoricalArtifactRole,
        UInt32
    )
}

/// Complete, projection-ready historical semantic artifact namespace.
///
/// This contract is deliberately independent of
/// `PrimeNativeNeuralGateReplayArtifactOutputContract.frozenV4`. It binds the
/// exact seven fixed artifacts and fifteen invariant chunks for each historical
/// worker role without changing ReplayTransport, executing a worker, or
/// granting any mechanics, capability, publication, or receipt authority.
public struct
    PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let preservedV4ContractID: String
    public let preservedV4ContractSHA256: String
    public let historicalRoles:
        [PrimeNativeNeuralGateHistoricalArtifactRole]
    public let exactInvariantRecordCount: Int
    public let invariantRecordsPerFullChunk: Int
    public let exactInvariantChunkCount: Int
    public let finalInvariantChunkRecordCount: Int
    public let maximumCanonicalJSONByteCount: UInt64
    public let maximumStatisticsJSONByteCount: UInt64
    public let maximumInvariantStreamByteCount: UInt64
    public let artifactSpecs:
        [PrimeNativeNeuralGateArtifactSpec]
    public let projectionCodecImplementedHere: Bool
    public let boundedHistoricalDecoderIntegrated: Bool
    public let descriptorStreamingDecoderIntegrated: Bool
    public let replayTransportAltered: Bool
    public let workerRequestHandlingImplemented: Bool
    public let workerExecutionImplemented: Bool
    public let artifactPublicationAuthorized: Bool
    public let mechanicsPassAuthorized: Bool
    public let capabilityAuthorized: Bool
    public let receiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let authorityStatement: String

    public static let frozenV1: Self = {
        let specs = Self.allKeys
            .compactMap(Self.makeSpec)
            .sorted { $0.relativePath < $1.relativePath }
        return Self(
            schemaVersion: 1,
            contractID:
                "prime_stage_b_complete_non_authorizing_historical_semantic_artifact_namespace_v1",
            preservedV4ContractID:
                "prime_stage_b_non_authorizing_semantic_output_namespace_v4",
            preservedV4ContractSHA256:
                "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
            historicalRoles:
                PrimeNativeNeuralGateHistoricalArtifactRole
                .allCases,
            exactInvariantRecordCount: 59_497,
            invariantRecordsPerFullChunk: 4_096,
            exactInvariantChunkCount: 15,
            finalInvariantChunkRecordCount: 2_153,
            maximumCanonicalJSONByteCount:
                1_048_576,
            maximumStatisticsJSONByteCount:
                16_777_216,
            maximumInvariantStreamByteCount:
                1_073_741_824,
            artifactSpecs: specs,
            projectionCodecImplementedHere: false,
            boundedHistoricalDecoderIntegrated: false,
            descriptorStreamingDecoderIntegrated: false,
            replayTransportAltered: false,
            workerRequestHandlingImplemented: false,
            workerExecutionImplemented: false,
            artifactPublicationAuthorized: false,
            mechanicsPassAuthorized: false,
            capabilityAuthorized: false,
            receiptAuthorized: false,
            sourceBindingV7Issued: false,
            authorityStatement:
                "This additive V1 overlay preserves the exact frozen V4 namespace and supplies only the complete projection-ready historical semantic artifact names, encodings, decoder obligations, role-specific owners, and terminal-verifier readers for a separate historical-only projection codec. It implements no codec or decoder in this target, does not alter ReplayTransport, implement request handling or worker execution, encode or publish evidence, authorize mechanics PASS or capability, seal a receipt, or issue source binding V7."
        )
    }()

    public static func allKeys(
        for role:
            PrimeNativeNeuralGateHistoricalArtifactRole
    ) -> [PrimeNativeNeuralGateHistoricalSemanticArtifactKey] {
        [
            .materialIdentityManifest(role),
            .gateObservation(role),
            .invariantRecordsManifest(role),
            .invariantRecordsGlobal(role),
            .fingerprintObservation(role),
            .mutationObservations(role),
            .statisticsVerdictObservation(role),
        ]
        + (0 ..< 15).map {
            .invariantChunk(role, UInt32($0))
        }
    }

    public func spec(
        for key:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
    ) throws -> PrimeNativeNeuralGateArtifactSpec {
        try validate()
        guard let value = Self.makeSpec(key)
        else {
            throw PrimeNativeNeuralGateArtifactContractError
                .invalidArtifactKey
        }
        try value.validate(
            maximumBoundedInMemoryByteCount:
                maximumStatisticsJSONByteCount
        )
        return value
    }

    public func invariantRecordCount(
        forChunkOrdinal ordinal: UInt32
    ) throws -> Int {
        guard ordinal < UInt32(exactInvariantChunkCount)
        else {
            throw PrimeNativeNeuralGateArtifactContractError
                .invalidArtifactKey
        }
        return ordinal
            == UInt32(exactInvariantChunkCount - 1)
            ? finalInvariantChunkRecordCount
            : invariantRecordsPerFullChunk
    }

    public func validate() throws {
        let expectedSpecs = Self.allKeys
            .compactMap(Self.makeSpec)
            .sorted { $0.relativePath < $1.relativePath }
        guard self == .frozenV1,
              schemaVersion == 1,
              preservedV4ContractID
                == PrimeNativeNeuralGateReplayArtifactOutputContract
                .frozenV4.contractID,
              preservedV4ContractSHA256
                == "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
              historicalRoles
                == PrimeNativeNeuralGateHistoricalArtifactRole
                .allCases,
              exactInvariantRecordCount == 59_497,
              invariantRecordsPerFullChunk == 4_096,
              exactInvariantChunkCount == 15,
              finalInvariantChunkRecordCount == 2_153,
              invariantRecordsPerFullChunk
                * (exactInvariantChunkCount - 1)
                + finalInvariantChunkRecordCount
                == exactInvariantRecordCount,
              maximumCanonicalJSONByteCount
                == 1_048_576,
              maximumStatisticsJSONByteCount
                == 16_777_216,
              maximumInvariantStreamByteCount
                == 1_073_741_824,
              artifactSpecs == expectedSpecs,
              artifactSpecs.count == 44,
              Set(artifactSpecs.map(\.relativePath)).count
                == artifactSpecs.count,
              !projectionCodecImplementedHere,
              !boundedHistoricalDecoderIntegrated,
              !descriptorStreamingDecoderIntegrated,
              !replayTransportAltered,
              !workerRequestHandlingImplemented,
              !workerExecutionImplemented,
              !artifactPublicationAuthorized,
              !mechanicsPassAuthorized,
              !capabilityAuthorized,
              !receiptAuthorized,
              !sourceBindingV7Issued
        else {
            throw PrimeNativeNeuralGateArtifactContractError
                .invalidFrozenContract
        }

        for role in historicalRoles {
            let keys = Self.allKeys(for: role)
            guard keys.count == 22,
                  keys.compactMap(Self.makeSpec).count
                    == 22
            else {
                throw PrimeNativeNeuralGateArtifactContractError
                    .invalidFrozenContract
            }
        }
        for spec in artifactSpecs {
            try spec.validate(
                maximumBoundedInMemoryByteCount:
                    maximumStatisticsJSONByteCount
            )
            guard spec.allowedReaders
                    == [.terminalVerifier],
                  !spec
                    .transportCanAuthorizeMechanicsPass,
                  !spec.transportCanAuthorizeCapability,
                  !spec.transportCanAuthorizeReceipt
            else {
                throw PrimeNativeNeuralGateArtifactContractError
                    .invalidArtifactSpec(
                        spec.relativePath
                    )
            }
        }
    }

    private static let allKeys =
        PrimeNativeNeuralGateHistoricalArtifactRole
        .allCases.flatMap(allKeys(for:))

    private static func makeSpec(
        _ key:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
    ) -> PrimeNativeNeuralGateArtifactSpec? {
        let role:
            PrimeNativeNeuralGateHistoricalArtifactRole
        let schemaID: String
        let leafPath: String
        let maximumByteCount: UInt64
        let encoding:
            PrimeNativeNeuralGateArtifactEncoding
        let decoderMode:
            PrimeNativeNeuralGateArtifactDecoderMode

        switch key {
        case let .materialIdentityManifest(value):
            role = value
            schemaID =
                "prime_stage_b_historical_material_identity_manifest_v1"
            leafPath =
                "material-identity-manifest.v1.json"
            maximumByteCount = 1_048_576
            encoding = .canonicalJSON
            decoderMode = .boundedCanonicalJSON
        case let .gateObservation(value):
            role = value
            schemaID =
                "prime_stage_b_historical_gate_observation_v1"
            leafPath = "gate-observation.v1.json"
            maximumByteCount = 1_048_576
            encoding = .canonicalJSON
            decoderMode = .boundedCanonicalJSON
        case let .invariantRecordsManifest(value):
            role = value
            schemaID =
                "prime_stage_b_historical_invariant_observation_v1"
            leafPath =
                "invariant-records-manifest.v1.json"
            maximumByteCount = 1_048_576
            encoding = .canonicalJSON
            decoderMode = .boundedCanonicalJSON
        case let .invariantRecordsGlobal(value):
            role = value
            schemaID =
                "prime_stage_b_historical_invariant_records_v1"
            leafPath = "invariant-records.v1.bin"
            maximumByteCount = 1_073_741_824
            encoding = .rawUTF8InvariantGlobal
            decoderMode = .descriptorStreamingRequired
        case let .fingerprintObservation(value):
            role = value
            schemaID =
                "prime_stage_b_historical_fingerprint_observation_v1"
            leafPath = "fingerprint-observation.v1.json"
            maximumByteCount = 1_048_576
            encoding = .canonicalJSON
            decoderMode = .boundedCanonicalJSON
        case let .mutationObservations(value):
            role = value
            schemaID =
                "prime_stage_b_historical_mutation_observation_v1"
            leafPath = "mutation-observations.v1.json"
            maximumByteCount = 1_048_576
            encoding = .canonicalJSON
            decoderMode = .boundedCanonicalJSON
        case let .statisticsVerdictObservation(value):
            role = value
            schemaID =
                "prime_stage_b_historical_keyed_three_seed_statistics_verdict_observation_v1"
            leafPath =
                "statistics-verdict-observation.v1.json"
            maximumByteCount = 16_777_216
            encoding = .canonicalJSON
            decoderMode = .boundedCanonicalJSON
        case let .invariantChunk(value, ordinal):
            guard ordinal < 15 else {
                return nil
            }
            role = value
            schemaID =
                "prime_stage_b_historical_invariant_chunk_v1"
            leafPath =
                "invariant-chunks/\(ordinalPath(ordinal)).v1.bin"
            maximumByteCount = 1_073_741_824
            encoding = .rawUTF8InvariantChunk
            decoderMode = .descriptorStreamingRequired
        }

        return PrimeNativeNeuralGateArtifactSpec(
            schemaID: schemaID,
            schemaVersion: 1,
            relativePath:
                "neural-gate-replay/historical/\(role.rawValue)/\(leafPath)",
            maximumByteCount: maximumByteCount,
            encoding: encoding,
            decoderMode: decoderMode,
            purpose: .immutableData,
            mode: "0444",
            owner: historicalOwner(role),
            allowedReaders: [.terminalVerifier],
            transportCanAuthorizeMechanicsPass:
                false,
            transportCanAuthorizeCapability: false,
            transportCanAuthorizeReceipt: false
        )
    }

    private static func ordinalPath(
        _ ordinal: UInt32
    ) -> String {
        String(format: "%08u", ordinal)
    }

    private static func historicalOwner(
        _ role:
            PrimeNativeNeuralGateHistoricalArtifactRole
    ) -> PrimeNativeNeuralGateArtifactOwner {
        switch role {
        case .probe:
            .historicalWorkerProbe
        case .verifier:
            .historicalWorkerVerifier
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case preservedV4ContractID =
            "preserved_v4_contract_id"
        case preservedV4ContractSHA256 =
            "preserved_v4_contract_sha256"
        case historicalRoles = "historical_roles"
        case exactInvariantRecordCount =
            "exact_invariant_record_count"
        case invariantRecordsPerFullChunk =
            "invariant_records_per_full_chunk"
        case exactInvariantChunkCount =
            "exact_invariant_chunk_count"
        case finalInvariantChunkRecordCount =
            "final_invariant_chunk_record_count"
        case maximumCanonicalJSONByteCount =
            "maximum_canonical_json_byte_count"
        case maximumStatisticsJSONByteCount =
            "maximum_statistics_json_byte_count"
        case maximumInvariantStreamByteCount =
            "maximum_invariant_stream_byte_count"
        case artifactSpecs = "artifact_specs"
        case projectionCodecImplementedHere =
            "projection_codec_implemented_here"
        case boundedHistoricalDecoderIntegrated =
            "bounded_historical_decoder_integrated"
        case descriptorStreamingDecoderIntegrated =
            "descriptor_streaming_decoder_integrated"
        case replayTransportAltered =
            "replay_transport_altered"
        case workerRequestHandlingImplemented =
            "worker_request_handling_implemented"
        case workerExecutionImplemented =
            "worker_execution_implemented"
        case artifactPublicationAuthorized =
            "artifact_publication_authorized"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case capabilityAuthorized =
            "capability_authorized"
        case receiptAuthorized = "receipt_authorized"
        case sourceBindingV7Issued =
            "source_binding_v7_issued"
        case authorityStatement = "authority_statement"
    }
}
