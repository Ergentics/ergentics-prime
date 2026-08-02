// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import PrimeNativeNeuralGateReplayArtifactContracts
import XCTest

final class
    PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
    private typealias Key =
        PrimeNativeNeuralGateHistoricalSemanticArtifactKey

    func testFrozenV4RemainsExactAndOverlayIsAdditive()
        throws
    {
        let v4 =
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4
        let overlay = Contract.frozenV1

        XCTAssertNoThrow(try v4.validate())
        XCTAssertEqual(v4.artifactSpecs.count, 116)
        XCTAssertEqual(v4.fixedRelativePaths.count, 35)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(v4)
            ),
            "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1"
        )
        XCTAssertEqual(
            overlay.preservedV4ContractID,
            v4.contractID
        )
        XCTAssertEqual(
            overlay.preservedV4ContractSHA256,
            "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1"
        )
        XCTAssertFalse(overlay.replayTransportAltered)
        XCTAssertNoThrow(try overlay.validate())
    }

    func testOverlayCanonicalIdentityIsPinned()
        throws
    {
        let contract = Contract.frozenV1
        let data = try PrimeCanonicalJSON.encode(contract)
        let decoded = try PrimeCanonicalJSON.decode(
            Contract.self,
            from: data
        )

        XCTAssertEqual(decoded, contract)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(
            try PrimeCanonicalJSON.encode(decoded),
            data
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: data),
            "eaabb04be1147b89c2e93a1dacd2c8a135383343c61a9e1756b5e7fcc3498c80"
        )
    }

    func testOverlayHasExactUniqueSafeFortyFourSpecs()
        throws
    {
        let contract = Contract.frozenV1
        let specs = contract.artifactSpecs

        XCTAssertEqual(specs.count, 44)
        XCTAssertEqual(
            Set(specs.map(\.relativePath)).count,
            44
        )
        XCTAssertEqual(
            specs.map(\.relativePath),
            specs.map(\.relativePath).sorted()
        )
        XCTAssertEqual(
            contract.exactInvariantRecordCount,
            59_497
        )
        XCTAssertEqual(
            contract.invariantRecordsPerFullChunk,
            4_096
        )
        XCTAssertEqual(
            contract.exactInvariantChunkCount,
            15
        )
        XCTAssertEqual(
            contract.finalInvariantChunkRecordCount,
            2_153
        )
        XCTAssertEqual(
            14 * contract.invariantRecordsPerFullChunk
                + contract.finalInvariantChunkRecordCount,
            contract.exactInvariantRecordCount
        )

        for spec in specs {
            XCTAssertNoThrow(
                try spec.validate(
                    maximumBoundedInMemoryByteCount:
                        contract
                        .maximumStatisticsJSONByteCount
                )
            )
            XCTAssertEqual(spec.schemaVersion, 1)
            XCTAssertEqual(spec.purpose, .immutableData)
            XCTAssertEqual(spec.mode, "0444")
            XCTAssertEqual(
                spec.allowedReaders,
                [.terminalVerifier]
            )
            XCTAssertFalse(
                spec.transportCanAuthorizeMechanicsPass
            )
            XCTAssertFalse(
                spec.transportCanAuthorizeCapability
            )
            XCTAssertFalse(
                spec.transportCanAuthorizeReceipt
            )
        }

        XCTAssertFalse(
            contract.workerRequestHandlingImplemented
        )
        XCTAssertFalse(contract.workerExecutionImplemented)
        XCTAssertFalse(
            contract.artifactPublicationAuthorized
        )
        XCTAssertFalse(
            contract.projectionCodecImplementedHere
        )
        XCTAssertFalse(
            contract.boundedHistoricalDecoderIntegrated
        )
        XCTAssertFalse(
            contract.descriptorStreamingDecoderIntegrated
        )
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(contract.capabilityAuthorized)
        XCTAssertFalse(contract.receiptAuthorized)
        XCTAssertFalse(contract.sourceBindingV7Issued)
    }

    func testEachRoleHasExactSevenFixedAndFifteenChunkSpecs()
        throws
    {
        let contract = Contract.frozenV1

        for role in
            PrimeNativeNeuralGateHistoricalArtifactRole
            .allCases
        {
            let prefix =
                "neural-gate-replay/historical/\(role.rawValue)/"
            let owner:
                PrimeNativeNeuralGateArtifactOwner =
                role == .probe
                ? .historicalWorkerProbe
                : .historicalWorkerVerifier
            let keys = Contract.allKeys(for: role)
            let specs = try keys.map(contract.spec(for:))

            XCTAssertEqual(keys.count, 22)
            XCTAssertEqual(Set(keys).count, 22)
            XCTAssertEqual(specs.count, 22)
            XCTAssertTrue(
                specs.allSatisfy {
                    $0.relativePath.hasPrefix(prefix)
                }
            )
            XCTAssertTrue(
                specs.allSatisfy { $0.owner == owner }
            )
            XCTAssertEqual(
                specs.filter {
                    $0.decoderMode
                        == .boundedCanonicalJSON
                }.count,
                6
            )
            XCTAssertEqual(
                specs.filter {
                    $0.decoderMode
                        == .descriptorStreamingRequired
                }.count,
                16
            )
        }
    }

    func testFixedPathsSchemasEncodingsAndLimitsAreExact()
        throws
    {
        let contract = Contract.frozenV1

        for role in
            PrimeNativeNeuralGateHistoricalArtifactRole
            .allCases
        {
            let prefix =
                "neural-gate-replay/historical/\(role.rawValue)/"
            let expected:
                [(Key, String, String, UInt64)] = [
                (
                    .materialIdentityManifest(role),
                    "material-identity-manifest.v1.json",
                    "prime_stage_b_historical_material_identity_manifest_v1",
                    1_048_576
                ),
                (
                    .gateObservation(role),
                    "gate-observation.v1.json",
                    "prime_stage_b_historical_gate_observation_v1",
                    1_048_576
                ),
                (
                    .invariantRecordsManifest(role),
                    "invariant-records-manifest.v1.json",
                    "prime_stage_b_historical_invariant_observation_v1",
                    1_048_576
                ),
                (
                    .fingerprintObservation(role),
                    "fingerprint-observation.v1.json",
                    "prime_stage_b_historical_fingerprint_observation_v1",
                    1_048_576
                ),
                (
                    .mutationObservations(role),
                    "mutation-observations.v1.json",
                    "prime_stage_b_historical_mutation_observation_v1",
                    1_048_576
                ),
                (
                    .statisticsVerdictObservation(role),
                    "statistics-verdict-observation.v1.json",
                    "prime_stage_b_historical_keyed_three_seed_statistics_verdict_observation_v1",
                    16_777_216
                ),
            ]

            for value in expected {
                let spec = try contract.spec(for: value.0)
                XCTAssertEqual(
                    spec.relativePath,
                    prefix + value.1
                )
                XCTAssertEqual(spec.schemaID, value.2)
                XCTAssertEqual(
                    spec.maximumByteCount,
                    value.3
                )
                XCTAssertEqual(
                    spec.encoding,
                    .canonicalJSON
                )
                XCTAssertEqual(
                    spec.decoderMode,
                    .boundedCanonicalJSON
                )
            }

            let global = try contract.spec(
                for: .invariantRecordsGlobal(role)
            )
            XCTAssertEqual(
                global.relativePath,
                prefix + "invariant-records.v1.bin"
            )
            XCTAssertEqual(
                global.schemaID,
                "prime_stage_b_historical_invariant_records_v1"
            )
            XCTAssertEqual(
                global.maximumByteCount,
                1_073_741_824
            )
            XCTAssertEqual(
                global.encoding,
                .rawUTF8InvariantGlobal
            )
            XCTAssertEqual(
                global.decoderMode,
                .descriptorStreamingRequired
            )
        }
    }

    func testAllFifteenChunksAreExactAndOrdinalFifteenFailsClosed()
        throws
    {
        let contract = Contract.frozenV1

        for role in
            PrimeNativeNeuralGateHistoricalArtifactRole
            .allCases
        {
            let prefix =
                "neural-gate-replay/historical/\(role.rawValue)/invariant-chunks/"
            for ordinal in UInt32(0) ..< UInt32(15) {
                let spec = try contract.spec(
                    for: .invariantChunk(role, ordinal)
                )
                XCTAssertEqual(
                    spec.relativePath,
                    prefix
                        + String(
                            format: "%08u",
                            ordinal
                        )
                        + ".v1.bin"
                )
                XCTAssertEqual(
                    spec.schemaID,
                    "prime_stage_b_historical_invariant_chunk_v1"
                )
                XCTAssertEqual(
                    spec.maximumByteCount,
                    1_073_741_824
                )
                XCTAssertEqual(
                    spec.encoding,
                    .rawUTF8InvariantChunk
                )
                XCTAssertEqual(
                    spec.decoderMode,
                    .descriptorStreamingRequired
                )
                XCTAssertEqual(
                    try contract.invariantRecordCount(
                        forChunkOrdinal: ordinal
                    ),
                    ordinal == 14 ? 2_153 : 4_096
                )
            }

            XCTAssertThrowsError(
                try contract.spec(
                    for: .invariantChunk(role, 15)
                )
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeNativeNeuralGateArtifactContractError,
                    .invalidArtifactKey
                )
            }
        }
        XCTAssertThrowsError(
            try contract.invariantRecordCount(
                forChunkOrdinal: 15
            )
        )
    }
}
