// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import XCTest
@testable import PrimeNativeNeuralGateHistoricalEvidenceExportMechanics
@testable import PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection
import PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder
import PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts
@testable import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateSemanticRecordContracts

final class PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderTests:
    XCTestCase
{
    func testPureStatisticsContractIsWireEquivalentToFrozenV16()
        throws
    {
        for role in PrimeNativeNeuralGateHistoricalArtifactRole.allCases {
            let frozen = try FrozenStatisticsEnvelope.syntheticForDecoderTest(
                invocationRole: role
            )
            let bytes = try frozen.canonicalData()
            let decoded = try
                PrimeNativeNeuralGateHistoricalStatisticsArtifactEnvelope
                .decodeCanonical(bytes)

            XCTAssertEqual(decoded.invocationRole, role)
            XCTAssertEqual(decoded.admittedSeeds, [.seed1618, .seed2718, .seed3141])
            XCTAssertEqual(decoded.orderedSeedEntries.count, 3)
            XCTAssertEqual(decoded.historicalCriticalLegValues.count, 10)
            XCTAssertEqual(try decoded.canonicalData(), bytes)
        }
    }

    func testCanonicalLeavesDecodeBothRolesAndPreserveSixBindings()
        throws
    {
        for role in PrimeNativeNeuralGateHistoricalArtifactRole.allCases {
            let inputs = try canonicalInputs(for: role)
            let decoded = try Decoder.decodeCanonicalLeaves(
                invocationRole: role,
                artifacts: inputs
            )

            XCTAssertEqual(decoded.invocationRole, role)
            XCTAssertEqual(decoded.materialIdentity.invocationRole, role)
            XCTAssertEqual(decoded.gate.invocationRole, role)
            XCTAssertEqual(decoded.invariantManifest.invocationRole, role)
            XCTAssertEqual(decoded.fingerprint.invocationRole, role)
            XCTAssertEqual(decoded.mutations.invocationRole, role)
            XCTAssertEqual(decoded.statistics.invocationRole, role)
            XCTAssertEqual(decoded.canonicalJSONBindings.count, 6)
            XCTAssertEqual(
                decoded.canonicalJSONBindings.map(\.key),
                canonicalKeys(for: role)
            )
            XCTAssertFalse(decoded.artifactWritePerformed)
            XCTAssertFalse(decoded.evidencePublished)
            XCTAssertFalse(decoded.mechanicsPassAuthorized)
            XCTAssertFalse(decoded.terminalReceiptAuthorized)
            XCTAssertFalse(decoded.sourceBindingV7Issued)
            XCTAssertFalse(decoded.scientificAuthorityAuthorized)
            XCTAssertFalse(decoded.productAuthorityAuthorized)

            for input in inputs {
                let binding = try decoded.binding(for: input.key)
                XCTAssertEqual(binding.byteCount, UInt64(input.bytes.count))
                XCTAssertEqual(
                    binding.sha256,
                    PrimeNativeNeuralGateInvariantCodec.sha256(input.bytes)
                )
            }
            XCTAssertThrowsError(
                try decoded.binding(for: .invariantChunk(role, 15))
            ) { error in
                XCTAssertEqual(
                    error as? DecoderError,
                    .invalidArtifactBinding("artifact_key")
                )
            }
        }
    }

    func testCanonicalLeafInputsAreKeyedAndRejectCoverageOrRoleDrift()
        throws
    {
        let probe = try canonicalInputs(for: .probe)
        let baseline = try Decoder.decodeCanonicalLeaves(
            invocationRole: .probe,
            artifacts: probe
        )
        let permuted = try Decoder.decodeCanonicalLeaves(
            invocationRole: .probe,
            artifacts: Array(probe.reversed())
        )
        XCTAssertEqual(permuted, baseline)

        XCTAssertThrowsError(
            try Decoder.decodeCanonicalLeaves(
                invocationRole: .probe,
                artifacts: probe + [try XCTUnwrap(probe.first)]
            )
        ) { error in
            guard case DecoderError.duplicateArtifactKey = error else {
                return XCTFail("expected duplicateArtifactKey, got \(error)")
            }
        }

        XCTAssertThrowsError(
            try Decoder.decodeCanonicalLeaves(
                invocationRole: .probe,
                artifacts: Array(probe.dropLast())
            )
        ) { error in
            guard case DecoderError.missingArtifactKey = error else {
                return XCTFail("expected missingArtifactKey, got \(error)")
            }
        }

        let verifierMaterial = try XCTUnwrap(
            try canonicalInputs(for: .verifier).first
        )
        XCTAssertThrowsError(
            try Decoder.decodeCanonicalLeaves(
                invocationRole: .probe,
                artifacts: Array(probe.dropFirst()) + [verifierMaterial]
            )
        ) { error in
            guard case DecoderError.unexpectedArtifactKey = error else {
                return XCTFail("expected unexpectedArtifactKey, got \(error)")
            }
        }
    }

    func testCanonicalLeafPreflightRejectsBoundsUTF8AndByteDrift()
        throws
    {
        let inputs = try canonicalInputs(for: .probe)
        let materialKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .materialIdentityManifest(.probe)
        let gateKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .gateObservation(.probe)

        assertDecodeFails(
            replacing(inputs, key: materialKey, bytes: Data()),
            as: .emptyArtifact
        )
        assertDecodeFails(
            replacing(
                inputs,
                key: materialKey,
                bytes: Data(repeating: 0x20, count: 1_048_577)
            ),
            as: .artifactTooLarge
        )
        assertDecodeFails(
            replacing(
                inputs,
                key: materialKey,
                bytes: Data([0xff])
            ),
            as: .invalidUTF8
        )

        var noncanonical = try input(for: materialKey, in: inputs).bytes
        noncanonical.append(0x0a)
        assertDecodeFails(
            replacing(inputs, key: materialKey, bytes: noncanonical),
            as: .nonCanonicalJSON
        )

        let authorityMutation = try mutateCanonicalJSONObject(
            input(for: gateKey, in: inputs).bytes
        ) {
            $0["mechanics_pass_authorized"] = true
        }
        assertDecodeFails(
            replacing(inputs, key: gateKey, bytes: authorityMutation),
            as: .nonCanonicalJSON
        )
    }

    func testCanonicalLeafCrossJoinsRejectReferenceMutationAndLegDrift()
        throws
    {
        let inputs = try canonicalInputs(for: .probe)
        let gateKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .gateObservation(.probe)
        let mutationKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .mutationObservations(.probe)
        let fingerprintKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .fingerprintObservation(.probe)
        let statisticsKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .statisticsVerdictObservation(.probe)

        let gateMutation = try mutateCanonicalJSONObject(
            input(for: gateKey, in: inputs).bytes
        ) { root in
            var reference = root["material_identity"] as! [String: Any]
            reference["content_sha256"] = String(repeating: "0", count: 64)
            root["material_identity"] = reference
        }
        assertDecodeFails(
            replacing(inputs, key: gateKey, bytes: gateMutation),
            as: .invalidArtifactSet
        )

        let widenedMutation = try mutateCanonicalJSONObject(
            input(for: mutationKey, in: inputs).bytes
        ) { root in
            var observations = root["observations"] as! [[String: Any]]
            var first = observations[0]
            first["allowed_failed_leg_ids"] = [
                PrimeNativeNeuralGateReplayLegDomain
                    .historicalCriticalLegIDs[0],
                PrimeNativeNeuralGateReplayLegDomain
                    .historicalCriticalLegIDs[1],
            ]
            observations[0] = first
            root["observations"] = observations
        }
        assertDecodeFails(
            replacing(inputs, key: mutationKey, bytes: widenedMutation),
            as: .invalidArtifactSet
        )

        let baselineDrift = try mutateCanonicalJSONObject(
            input(for: mutationKey, in: inputs).bytes
        ) { root in
            var observations = root["observations"] as! [[String: Any]]
            observations[0]["baseline_stream_sha256"] =
                String(repeating: "e", count: 64)
            root["observations"] = observations
        }
        assertDecodeFails(
            replacing(inputs, key: mutationKey, bytes: baselineDrift),
            as: .invalidArtifactSet
        )

        let divergentStreamSHA =
            PrimeNativeNeuralGateInvariantCodec.sha256(
                Data("cross_leaf_fingerprint_drift".utf8)
            )
        let fingerprintDrift = try mutateCanonicalJSONObject(
            input(for: fingerprintKey, in: inputs).bytes
        ) { root in
            var observation = root["observation"] as! [String: Any]
            observation["ordered_multiset_stream_sha256"] =
                divergentStreamSHA
            observation["cache_key"] =
                PrimeNativeNeuralGateFingerprintMechanics.cacheKey(
                    streamSHA256: divergentStreamSHA
                )
            root["observation"] = observation
        }
        let gateForFingerprintDrift = try mutateCanonicalJSONObject(
            input(for: gateKey, in: inputs).bytes
        ) { root in
            var reference = root["fingerprint_observation"]
                as! [String: Any]
            reference["content_sha256"] =
                PrimeNativeNeuralGateInvariantCodec.sha256(
                    fingerprintDrift
                )
            reference["byte_count"] = fingerprintDrift.count
            root["fingerprint_observation"] = reference
        }
        assertDecodeFails(
            replacing(
                replacing(
                    inputs,
                    key: fingerprintKey,
                    bytes: fingerprintDrift
                ),
                key: gateKey,
                bytes: gateForFingerprintDrift
            ),
            as: .invalidArtifactSet
        )

        let carrierDrift = try mutateCanonicalJSONObject(
            input(for: statisticsKey, in: inputs).bytes
        ) { root in
            var values = root["historical_critical_leg_values"]
                as! [[String: Any]]
            values[0]["passed"] = false
            root["historical_critical_leg_values"] = values
        }
        assertDecodeFails(
            replacing(inputs, key: statisticsKey, bytes: carrierDrift),
            as: .invalidArtifactSet
        )
    }

    func testCompleteTwoRoleSemanticArtifactSetsBindAllTwentyTwoArtifacts()
        throws
    {
        let exactRecordCount =
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1.exactInvariantRecordCount
        for role in PrimeNativeNeuralGateHistoricalArtifactRole.allCases {
            let inputs = try allInputs(for: role)
            XCTAssertEqual(inputs.count, 22)
            let projected = try DecoderTestFixtures.artifacts(for: role)
            let decoder = try StreamDecoder(
                decodedLeaves: decodedLeaves(for: role)
            )
            _ = try feedCompleteStreams(
                into: decoder,
                role: role,
                projected: projected
            )
            let decoded = try decoder.finishSemanticArtifactSet()

            XCTAssertEqual(decoded.canonicalLeaves.invocationRole, role)
            XCTAssertEqual(
                decoded.invariantStreams.global.observedRecordCount,
                exactRecordCount
            )
            XCTAssertEqual(decoded.invariantStreams.orderedChunks.count, 15)
            XCTAssertEqual(
                decoded.invariantStreams.matchedRecordCount,
                exactRecordCount
            )
            XCTAssertEqual(decoded.orderedArtifactBindings.count, 22)
            XCTAssertEqual(
                decoded.orderedArtifactBindings.map(\.key),
                PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
                    .allKeys(for: role)
            )
            for input in inputs {
                let binding = try XCTUnwrap(
                    decoded.orderedArtifactBindings.first {
                        $0.key == input.key
                    }
                )
                XCTAssertEqual(binding.byteCount, UInt64(input.bytes.count))
                XCTAssertEqual(
                    binding.sha256,
                    PrimeNativeNeuralGateInvariantCodec.sha256(input.bytes)
                )
            }
            XCTAssertFalse(decoded.artifactWritePerformed)
            XCTAssertFalse(decoded.evidencePublished)
            XCTAssertFalse(decoded.mechanicsPassAuthorized)
            XCTAssertFalse(decoded.terminalReceiptAuthorized)
            XCTAssertFalse(decoded.sourceBindingV7Issued)
            XCTAssertFalse(decoded.scientificAuthorityAuthorized)
            XCTAssertFalse(decoded.productAuthorityAuthorized)
            XCTAssertEqual(
                try decoder.finishSemanticArtifactSet(),
                decoded
            )
        }
    }

    func testStreamFeedLimitAndMismatchPoisonTheSession()
        throws
    {
        let leaves = try decodedLeaves(for: .probe)
        let oversized = try StreamDecoder(decodedLeaves: leaves)
        XCTAssertThrowsError(
            try consume(
                Data(
                    repeating: 0,
                    count: Decoder.descriptorFeedMaximumByteCount + 1
                ),
                key: .invariantRecordsGlobal(.probe),
                into: oversized
            )
        ) { error in
            XCTAssertEqual(
                error as? DecoderError,
                .feedTooLarge(
                    Decoder.descriptorFeedMaximumByteCount + 1
                )
            )
        }
        XCTAssertThrowsError(
            try consume(
                Data(),
                key: .invariantRecordsGlobal(.probe),
                into: oversized
            )
        ) { error in
            XCTAssertEqual(error as? DecoderError, .decoderPoisoned)
        }

        let mismatch = try StreamDecoder(decodedLeaves: leaves)
        let projected = try DecoderTestFixtures.artifacts(for: .probe)
        let global = try projected.artifact(
            for: .invariantRecordsGlobal(.probe)
        ).bytes
        let alternate = try DecoderTestFixtures.alternateInvariant.get()
            .bundle.chunkStreams[0]
        try consume(
            Data(global.prefix(128)),
            key: .invariantRecordsGlobal(.probe),
            into: mismatch
        )
        XCTAssertThrowsError(
            try consume(
                Data(alternate.prefix(128)),
                key: .invariantChunk(.probe, 0),
                into: mismatch
            )
        ) { error in
            XCTAssertEqual(
                error as? DecoderError,
                .globalChunkRecordMismatch(0)
            )
        }
        XCTAssertThrowsError(
            try mismatch.finish()
        ) { error in
            XCTAssertEqual(error as? DecoderError, .decoderPoisoned)
        }
    }

    func testStreamCorruptionTruncationAndTrailingAreTypedAndPoisoning()
        throws
    {
        let leaves = try decodedLeaves(for: .probe)
        let projected = try DecoderTestFixtures.artifacts(for: .probe)
        let global = try projected.artifact(
            for: .invariantRecordsGlobal(.probe)
        ).bytes
        let firstChunk = try projected.artifact(
            for: .invariantChunk(.probe, 0)
        ).bytes

        let corrupt = try StreamDecoder(decodedLeaves: leaves)
        var corruptHeader = Data(global.prefix(32))
        corruptHeader[corruptHeader.startIndex] = 0x58
        assertTypedStreamFailure {
            try consume(
                corruptHeader,
                key: .invariantRecordsGlobal(.probe),
                into: corrupt
            )
        }
        XCTAssertThrowsError(
            try consume(
                Data(),
                key: .invariantRecordsGlobal(.probe),
                into: corrupt
            )
        ) { error in
            XCTAssertEqual(error as? DecoderError, .decoderPoisoned)
        }

        let truncated = try StreamDecoder(decodedLeaves: leaves)
        try feed(
            Data(firstChunk.dropLast()),
            key: .invariantChunk(.probe, 0),
            into: truncated
        )
        assertTypedStreamFailure {
            try truncated.finishCurrentChunk()
        }
        XCTAssertThrowsError(
            try truncated.finish()
        ) { error in
            XCTAssertEqual(error as? DecoderError, .decoderPoisoned)
        }

        let trailing = try StreamDecoder(decodedLeaves: leaves)
        try feed(
            firstChunk,
            key: .invariantChunk(.probe, 0),
            into: trailing
        )
        XCTAssertThrowsError(
            try consume(
                Data([0]),
                key: .invariantChunk(.probe, 0),
                into: trailing
            )
        ) { error in
            guard case DecoderError.invalidStreamState = error else {
                return XCTFail("expected typed trailing rejection, got \(error)")
            }
        }
        XCTAssertThrowsError(
            try trailing.finish()
        ) { error in
            XCTAssertEqual(error as? DecoderError, .decoderPoisoned)
        }
    }

    func testNonzeroIndexDataSlicesAreAdmittedUnderExactKeys()
        throws
    {
        let leaves = try decodedLeaves(for: .probe)
        let projected = try DecoderTestFixtures.artifacts(for: .probe)
        let global = try projected.artifact(
            for: .invariantRecordsGlobal(.probe)
        ).bytes
        let firstChunk = try projected.artifact(
            for: .invariantChunk(.probe, 0)
        ).bytes
        let firstGlobalPartition = Data(
            global.prefix(firstChunk.count)
        )
        let decoder = try StreamDecoder(decodedLeaves: leaves)

        try feedNonzeroIndexSlices(
            firstGlobalPartition,
            key: .invariantRecordsGlobal(.probe),
            into: decoder
        )
        try feedNonzeroIndexSlices(
            firstChunk,
            key: .invariantChunk(.probe, 0),
            into: decoder
        )
        XCTAssertNoThrow(try decoder.finishCurrentChunk())
    }

    func testBoundedGlobalReadAheadAcrossChunkBoundaryCompletes()
        throws
    {
        let role = PrimeNativeNeuralGateHistoricalArtifactRole.probe
        let projected = try DecoderTestFixtures.artifacts(for: role)
        let global = try projected.artifact(
            for: .invariantRecordsGlobal(role)
        ).bytes
        let firstChunk = try projected.artifact(
            for: .invariantChunk(role, 0)
        ).bytes
        let secondChunk = try projected.artifact(
            for: .invariantChunk(role, 1)
        ).bytes
        let headerByteCount = try derivedFramedHeaderByteCount(
            projected: projected,
            role: role
        )
        let firstTwoGlobalByteCount =
            firstChunk.count + secondChunk.count - headerByteCount
        let readAheadEnd = global.index(
            global.startIndex,
            offsetBy: firstTwoGlobalByteCount
        )
        let decoder = try StreamDecoder(
            decodedLeaves: decodedLeaves(for: role)
        )

        // Two full 4,096-record partitions remain below the frozen 8,194
        // unmatched-record bound and cross the first chunk boundary.
        try feed(
            global[global.startIndex ..< readAheadEnd],
            key: .invariantRecordsGlobal(role),
            into: decoder
        )
        try feed(
            firstChunk,
            key: .invariantChunk(role, 0),
            into: decoder
        )
        try decoder.finishCurrentChunk()
        try feed(
            secondChunk,
            key: .invariantChunk(role, 1),
            into: decoder
        )
        try decoder.finishCurrentChunk()

        var globalOffset = firstTwoGlobalByteCount
        for ordinal in 2 ..< 15 {
            let chunk = try projected.artifact(
                for: .invariantChunk(role, UInt32(ordinal))
            ).bytes
            let globalCount = chunk.count - headerByteCount
            let globalEnd = globalOffset + globalCount
            try feed(
                global[
                    global.index(
                        global.startIndex,
                        offsetBy: globalOffset
                    ) ..< global.index(
                        global.startIndex,
                        offsetBy: globalEnd
                    )
                ],
                key: .invariantRecordsGlobal(role),
                into: decoder
            )
            try feed(
                chunk,
                key: .invariantChunk(role, UInt32(ordinal)),
                into: decoder
            )
            try decoder.finishCurrentChunk()
            globalOffset = globalEnd
        }
        XCTAssertEqual(globalOffset, global.count)
        let finished = try decoder.finish()
        XCTAssertEqual(finished.matchedRecordCount, 59_497)
        XCTAssertEqual(finished.orderedChunks.count, 15)
    }

    func testGlobalReadAheadRejectsRecordBeyondPendingBound()
        throws
    {
        let role = PrimeNativeNeuralGateHistoricalArtifactRole.probe
        let projected = try DecoderTestFixtures.artifacts(for: role)
        let global = try projected.artifact(
            for: .invariantRecordsGlobal(role)
        ).bytes
        let firstChunk = try projected.artifact(
            for: .invariantChunk(role, 0)
        ).bytes
        let secondChunk = try projected.artifact(
            for: .invariantChunk(role, 1)
        ).bytes
        let thirdChunk = try projected.artifact(
            for: .invariantChunk(role, 2)
        ).bytes
        let headerByteCount = try derivedFramedHeaderByteCount(
            projected: projected,
            role: role
        )
        let thirdChunkThreeRecordByteCount = try framedByteCount(
            throughRecordCount: 3,
            in: thirdChunk,
            kind: .chunk,
            requiredDeclaredRecordCount: 4_096
        )
        let readAheadByteCount = firstChunk.count
            + secondChunk.count
            - headerByteCount
            + thirdChunkThreeRecordByteCount
            - headerByteCount
        let readAheadEnd = global.index(
            global.startIndex,
            offsetBy: readAheadByteCount
        )
        let decoder = try StreamDecoder(
            decodedLeaves: decodedLeaves(for: role)
        )

        // 4,096 + 4,096 + 3 = 8,195. The first 8,194 unmatched records
        // are admissible; the next record must be rejected before append.
        XCTAssertThrowsError(
            try feed(
                global[global.startIndex ..< readAheadEnd],
                key: .invariantRecordsGlobal(role),
                into: decoder
            )
        ) { error in
            XCTAssertEqual(
                error as? DecoderError,
                .invalidStreamState("pending_queue_bound")
            )
        }
        XCTAssertThrowsError(try decoder.finish()) { error in
            XCTAssertEqual(error as? DecoderError, .decoderPoisoned)
        }
    }

    func testCanonicalJSONRejectsMalformedUnknownDuplicateAndStatisticsShape()
        throws
    {
        let inputs = try canonicalInputs(for: .probe)
        let materialKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .materialIdentityManifest(.probe)
        let statisticsKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .statisticsVerdictObservation(.probe)
        let material = try input(
            for: materialKey,
            in: inputs
        ).bytes

        for invalid in [
            Data("[]".utf8),
            Data("{".utf8),
        ] {
            XCTAssertThrowsError(
                try Decoder.decodeCanonicalLeaves(
                    invocationRole: .probe,
                    artifacts: replacing(
                        inputs,
                        key: materialKey,
                        bytes: invalid
                    )
                )
            ) { error in
                guard case DecoderError.invalidCanonicalJSON = error
                else {
                    return XCTFail(
                        "expected invalidCanonicalJSON, got \(error)"
                    )
                }
            }
        }

        let unknown = try mutateCanonicalJSONObject(material) {
            $0["unexpected_nested_authority"] = [
                "enabled": true,
            ]
        }
        assertDecodeFails(
            replacing(inputs, key: materialKey, bytes: unknown),
            as: .nonCanonicalJSON
        )

        var duplicate = Data("{\"schema_version\":1,".utf8)
        duplicate.append(material.dropFirst())
        assertDecodeFails(
            replacing(inputs, key: materialKey, bytes: duplicate),
            as: .nonCanonicalJSON
        )

        var byteOrderMark = Data([0xef, 0xbb, 0xbf])
        byteOrderMark.append(material)
        XCTAssertThrowsError(
            try Decoder.decodeCanonicalLeaves(
                invocationRole: .probe,
                artifacts: replacing(
                    inputs,
                    key: materialKey,
                    bytes: byteOrderMark
                )
            )
        )

        let missing = try mutateCanonicalJSONObject(material) {
            $0.removeValue(forKey: "source_bytes_resolved")
        }
        XCTAssertThrowsError(
            try Decoder.decodeCanonicalLeaves(
                invocationRole: .probe,
                artifacts: replacing(
                    inputs,
                    key: materialKey,
                    bytes: missing
                )
            )
        ) { error in
            guard case DecoderError.invalidCanonicalJSON = error
            else {
                return XCTFail(
                    "expected invalidCanonicalJSON, got \(error)"
                )
            }
        }

        let reducedSeeds = try mutateCanonicalJSONObject(
            input(for: statisticsKey, in: inputs).bytes
        ) {
            $0["admitted_seeds"] = [1_618, 2_718]
        }
        XCTAssertThrowsError(
            try Decoder.decodeCanonicalLeaves(
                invocationRole: .probe,
                artifacts: replacing(
                    inputs,
                    key: statisticsKey,
                    bytes: reducedSeeds
                )
            )
        ) { error in
            guard case DecoderError.invalidSemanticLeaf = error
            else {
                return XCTFail(
                    "expected invalidSemanticLeaf, got \(error)"
                )
            }
        }

        let statisticsAuthority = try mutateCanonicalJSONObject(
            input(for: statisticsKey, in: inputs).bytes
        ) {
            $0["product_authority_authorized"] = true
        }
        XCTAssertThrowsError(
            try Decoder.decodeCanonicalLeaves(
                invocationRole: .probe,
                artifacts: replacing(
                    inputs,
                    key: statisticsKey,
                    bytes: statisticsAuthority
                )
            )
        ) { error in
            guard case DecoderError.invalidSemanticLeaf = error else {
                return XCTFail(
                    "expected invalidSemanticLeaf, got \(error)"
                )
            }
        }
    }

    func testFirstPartitionAcceptsOneByteFragmentation()
        throws
    {
        let leaves = try decodedLeaves(for: .probe)
        let projected = try DecoderTestFixtures.artifacts(for: .probe)
        let global = try projected.artifact(
            for: .invariantRecordsGlobal(.probe)
        ).bytes
        let firstChunk = try projected.artifact(
            for: .invariantChunk(.probe, 0)
        ).bytes
        let decoder = try StreamDecoder(decodedLeaves: leaves)
        XCTAssertEqual(firstChunk.count, global.prefix(firstChunk.count).count)

        for offset in firstChunk.indices {
            let next = firstChunk.index(after: offset)
            try consume(
                Data(global[offset ..< next]),
                key: .invariantRecordsGlobal(.probe),
                into: decoder
            )
            try consume(
                Data(firstChunk[offset ..< next]),
                key: .invariantChunk(.probe, 0),
                into: decoder
            )
        }
        try decoder.finishCurrentChunk()
    }

    func testWrongRoleOrdinalAndCanonicalLeafStreamKeysPoison()
        throws
    {
        let leaves = try decodedLeaves(for: .probe)
        let projected = try DecoderTestFixtures.artifacts(for: .probe)
        let global = try projected.artifact(
            for: .invariantRecordsGlobal(.probe)
        ).bytes

        let wrongRole = try StreamDecoder(decodedLeaves: leaves)
        XCTAssertThrowsError(
            try consume(
                Data(global.prefix(32)),
                key: .invariantRecordsGlobal(.verifier),
                into: wrongRole
            )
        ) { error in
            guard case DecoderError.unexpectedArtifactKey = error else {
                return XCTFail("expected unexpectedArtifactKey, got \(error)")
            }
        }
        XCTAssertThrowsError(
            try wrongRole.finish()
        ) { error in
            XCTAssertEqual(error as? DecoderError, .decoderPoisoned)
        }

        let wrongOrdinal = try StreamDecoder(decodedLeaves: leaves)
        XCTAssertThrowsError(
            try consume(
                Data(),
                key: .invariantChunk(.probe, 1),
                into: wrongOrdinal
            )
        ) { error in
            XCTAssertEqual(error as? DecoderError, .invalidChunkOrdinal(1))
        }
        XCTAssertThrowsError(try wrongOrdinal.finish()) { error in
            XCTAssertEqual(error as? DecoderError, .decoderPoisoned)
        }

        let canonicalLeaf = try StreamDecoder(decodedLeaves: leaves)
        XCTAssertThrowsError(
            try consume(
                Data(),
                key: .materialIdentityManifest(.probe),
                into: canonicalLeaf
            )
        ) { error in
            guard case DecoderError.unexpectedArtifactKey = error else {
                return XCTFail("expected unexpectedArtifactKey, got \(error)")
            }
        }
        XCTAssertThrowsError(try canonicalLeaf.finish()) { error in
            XCTAssertEqual(error as? DecoderError, .decoderPoisoned)
        }
    }

    func testFingerprintRecordCountAndResidueDriftAreRejected()
        throws
    {
        let inputs = try canonicalInputs(for: .probe)
        let fingerprintKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .fingerprintObservation(.probe)
        let fingerprintBytes = try input(
            for: fingerprintKey,
            in: inputs
        ).bytes

        let recordCountDrift = try mutateCanonicalJSONObject(
            fingerprintBytes
        ) { root in
            var observation = root["observation"] as! [String: Any]
            var direct = observation["direct"] as! [String: Any]
            var accelerated = observation["accelerated"] as! [String: Any]
            direct["record_count"] = 59_496
            accelerated["record_count"] = 59_496
            observation["direct"] = direct
            observation["accelerated"] = accelerated
            root["observation"] = observation
        }
        assertDecodeFails(
            try replacingFingerprintAndGateBinding(
                inputs,
                fingerprintBytes: recordCountDrift
            ),
            as: .invalidArtifactSet
        )

        let residueDrift = try mutateCanonicalJSONObject(
            fingerprintBytes
        ) { root in
            var observation = root["observation"] as! [String: Any]
            var direct = observation["direct"] as! [String: Any]
            var accelerated = observation["accelerated"] as! [String: Any]
            var directResidues = direct["residues"] as! [Any]
            var acceleratedResidues = accelerated["residues"] as! [Any]
            directResidues[0] =
                PrimeNativeNeuralGateFingerprintMechanics.prime
            acceleratedResidues[0] =
                PrimeNativeNeuralGateFingerprintMechanics.prime
            direct["residues"] = directResidues
            accelerated["residues"] = acceleratedResidues
            observation["direct"] = direct
            observation["accelerated"] = accelerated
            root["observation"] = observation
        }
        assertDecodeFails(
            try replacingFingerprintAndGateBinding(
                inputs,
                fingerprintBytes: residueDrift
            ),
            as: .invalidArtifactSet
        )

        let mutationKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .mutationObservations(.probe)
        let mutationDrift = try mutateCanonicalJSONObject(
            input(for: mutationKey, in: inputs).bytes
        ) { root in
            var observations = root["observations"]
                as! [[String: Any]]
            var mutated = observations[0]["mutated_fingerprint"]
                as! [String: Any]
            var residues = mutated["residues"] as! [Any]
            mutated["record_count"] = 59_496
            residues[0] =
                PrimeNativeNeuralGateFingerprintMechanics.prime
            mutated["residues"] = residues
            observations[0]["mutated_fingerprint"] = mutated
            root["observations"] = observations
        }
        assertDecodeFails(
            try replacingLeafAndGateBinding(
                inputs,
                leafKey: mutationKey,
                gateReferenceName: "mutation_observation",
                leafBytes: mutationDrift
            ),
            as: .invalidArtifactSet
        )
    }

    private enum ExpectedDecodeFailure {
        case emptyArtifact
        case artifactTooLarge
        case invalidUTF8
        case nonCanonicalJSON
        case invalidArtifactSet
    }

    private func assertDecodeFails(
        _ inputs: [ArtifactInput],
        as expected: ExpectedDecodeFailure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try Decoder.decodeCanonicalLeaves(
                invocationRole: .probe,
                artifacts: inputs
            ),
            file: file,
            line: line
        ) { error in
            let matches: Bool
            switch (expected, error) {
            case (.emptyArtifact, DecoderError.emptyArtifact):
                matches = true
            case (.artifactTooLarge, DecoderError.artifactTooLarge):
                matches = true
            case (.invalidUTF8, DecoderError.invalidUTF8):
                matches = true
            case (.nonCanonicalJSON, DecoderError.nonCanonicalJSON):
                matches = true
            case (.invalidArtifactSet, DecoderError.invalidArtifactSet):
                matches = true
            default:
                matches = false
            }
            XCTAssertTrue(
                matches,
                "unexpected decoder error: \(error)",
                file: file,
                line: line
            )
        }
    }

    private func canonicalInputs(
        for role: PrimeNativeNeuralGateHistoricalArtifactRole
    ) throws -> [ArtifactInput] {
        let artifacts = try DecoderTestFixtures.artifacts(for: role)
        return try canonicalKeys(for: role).map { key in
            ArtifactInput(
                key: key,
                bytes: try artifacts.artifact(for: key).bytes
            )
        }
    }

    private func allInputs(
        for role: PrimeNativeNeuralGateHistoricalArtifactRole
    ) throws -> [ArtifactInput] {
        let artifacts = try DecoderTestFixtures.artifacts(for: role)
        return try
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .allKeys(for: role).map { key in
                ArtifactInput(
                    key: key,
                    bytes: try artifacts.artifact(for: key).bytes
                )
            }
    }

    private func decodedLeaves(
        for role: PrimeNativeNeuralGateHistoricalArtifactRole
    ) throws -> PrimeNativeNeuralGateHistoricalDecodedCanonicalLeaves {
        try Decoder.decodeCanonicalLeaves(
            invocationRole: role,
            artifacts: canonicalInputs(for: role)
        )
    }

    private func consume(
        _ data: Data,
        key: PrimeNativeNeuralGateHistoricalSemanticArtifactKey,
        into decoder: StreamDecoder
    ) throws {
        try decoder.consume(
            ArtifactInput(key: key, bytes: data)
        )
    }

    private func feed(
        _ data: Data,
        key: PrimeNativeNeuralGateHistoricalSemanticArtifactKey,
        into decoder: StreamDecoder
    ) throws {
        var offset = data.startIndex
        while offset < data.endIndex {
            let end = data.index(
                offset,
                offsetBy: min(
                    Decoder.descriptorFeedMaximumByteCount,
                    data.distance(from: offset, to: data.endIndex)
                )
            )
            try consume(
                data[offset ..< end],
                key: key,
                into: decoder
            )
            offset = end
        }
    }

    private func feedNonzeroIndexSlices(
        _ data: Data,
        key: PrimeNativeNeuralGateHistoricalSemanticArtifactKey,
        into decoder: StreamDecoder
    ) throws {
        var offset = data.startIndex
        while offset < data.endIndex {
            let end = data.index(
                offset,
                offsetBy: min(
                    Decoder.descriptorFeedMaximumByteCount,
                    data.distance(from: offset, to: data.endIndex)
                )
            )
            let sourceSlice = data[offset ..< end]
            var envelope = Data([0xa5])
            envelope.append(sourceSlice)
            envelope.append(0x5a)
            let slice = envelope[
                envelope.index(after: envelope.startIndex)
                    ..< envelope.index(before: envelope.endIndex)
            ]
            XCTAssertNotEqual(slice.startIndex, envelope.startIndex)
            XCTAssertEqual(Data(slice), Data(sourceSlice))
            try consume(slice, key: key, into: decoder)
            offset = end
        }
    }

    private func feedCompleteStreams(
        into decoder: StreamDecoder,
        role: PrimeNativeNeuralGateHistoricalArtifactRole,
        projected:
            PrimeNativeNeuralGateHistoricalProjectedArtifactSet
    ) throws -> PrimeNativeNeuralGateHistoricalDecodedInvariantStreams {
        let global = try projected.artifact(
            for: .invariantRecordsGlobal(role)
        ).bytes
        var globalOffset = global.startIndex
        let headerByteCount = try derivedFramedHeaderByteCount(
            projected: projected,
            role: role
        )
        for ordinal in 0 ..< 15 {
            let chunk = try projected.artifact(
                for: .invariantChunk(role, UInt32(ordinal))
            ).bytes
            let globalCount = chunk.count
                - (ordinal == 0 ? 0 : headerByteCount)
            let globalEnd = global.index(
                globalOffset,
                offsetBy: globalCount
            )
            try feed(
                global[globalOffset ..< globalEnd],
                key: .invariantRecordsGlobal(role),
                into: decoder
            )
            try feed(
                chunk,
                key: .invariantChunk(role, UInt32(ordinal)),
                into: decoder
            )
            try decoder.finishCurrentChunk()
            globalOffset = globalEnd
        }
        XCTAssertEqual(globalOffset, global.endIndex)
        _ = try decoder.finishGlobal()
        return try decoder.finish()
    }

    private func derivedFramedHeaderByteCount(
        projected:
            PrimeNativeNeuralGateHistoricalProjectedArtifactSet,
        role: PrimeNativeNeuralGateHistoricalArtifactRole
    ) throws -> Int {
        let globalByteCount = try projected.artifact(
            for: .invariantRecordsGlobal(role)
        ).bytes.count
        var chunkByteCount = 0
        for ordinal in 0 ..< 15 {
            let count = try projected.artifact(
                for: .invariantChunk(role, UInt32(ordinal))
            ).bytes.count
            let addition = chunkByteCount.addingReportingOverflow(count)
            guard !addition.overflow else {
                throw DecoderTestSupportError.integerOverflow
            }
            chunkByteCount = addition.partialValue
        }
        let extraHeaderCount = 14
        let difference = chunkByteCount.subtractingReportingOverflow(
            globalByteCount
        )
        guard !difference.overflow,
              difference.partialValue > 0,
              difference.partialValue.isMultiple(
                of: extraHeaderCount
              )
        else {
            throw DecoderTestSupportError.invalidFramedGeometry
        }
        return difference.partialValue / extraHeaderCount
    }

    private func framedByteCount(
        throughRecordCount requiredRecordCount: Int,
        in data: Data,
        kind: PrimeNativeNeuralGateInvariantFramedStreamKind,
        requiredDeclaredRecordCount: UInt64
    ) throws -> Int {
        let reader = PrimeNativeNeuralGateInvariantFramedRecordReader(
            kind: kind,
            limits: .stageB,
            requireCanonicalOrder: true,
            requiredDeclaredRecordCount: requiredDeclaredRecordCount
        )
        var observedRecordCount = 0
        var cursor = data.startIndex
        while cursor < data.endIndex,
              observedRecordCount < requiredRecordCount
        {
            let end = data.index(after: cursor)
            try reader.consume(data[cursor ..< end]) { _ in
                observedRecordCount += 1
            }
            cursor = end
        }
        guard observedRecordCount == requiredRecordCount else {
            throw DecoderTestSupportError.invalidFramedGeometry
        }
        return data.distance(from: data.startIndex, to: cursor)
    }

    private func assertTypedStreamFailure(
        _ operation: () throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try operation(),
            file: file,
            line: line
        ) { error in
            XCTAssertNotNil(
                error as? DecoderError,
                "stream error escaped shared decoder vocabulary: \(error)",
                file: file,
                line: line
            )
        }
    }

    private func canonicalKeys(
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

    private func input(
        for key: PrimeNativeNeuralGateHistoricalSemanticArtifactKey,
        in inputs: [ArtifactInput]
    ) throws -> ArtifactInput {
        try XCTUnwrap(inputs.first { $0.key == key })
    }

    private func replacing(
        _ inputs: [ArtifactInput],
        key: PrimeNativeNeuralGateHistoricalSemanticArtifactKey,
        bytes: Data
    ) -> [ArtifactInput] {
        inputs.map {
            $0.key == key ? ArtifactInput(key: key, bytes: bytes) : $0
        }
    }

    private func replacingFingerprintAndGateBinding(
        _ inputs: [ArtifactInput],
        fingerprintBytes: Data
    ) throws -> [ArtifactInput] {
        let fingerprintKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .fingerprintObservation(.probe)
        let fingerprintObject = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: fingerprintBytes
            ) as? [String: Any]
        )
        let observation = try XCTUnwrap(
            fingerprintObject["observation"] as? [String: Any]
        )
        let direct = try XCTUnwrap(
            observation["direct"] as? [String: Any]
        )
        let mutationKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .mutationObservations(.probe)
        let mutationBytes = try mutateCanonicalJSONObject(
            input(for: mutationKey, in: inputs).bytes
        ) { root in
            var observations = root["observations"]
                as! [[String: Any]]
            for index in observations.indices {
                observations[index]["baseline_fingerprint"] = direct
                observations[index]["restored_fingerprint"] = direct
            }
            root["observations"] = observations
        }
        let fingerprintReplaced = try replacingLeafAndGateBinding(
            inputs,
            leafKey: fingerprintKey,
            gateReferenceName: "fingerprint_observation",
            leafBytes: fingerprintBytes
        )
        return try replacingLeafAndGateBinding(
            fingerprintReplaced,
            leafKey: mutationKey,
            gateReferenceName: "mutation_observation",
            leafBytes: mutationBytes
        )
    }

    private func replacingLeafAndGateBinding(
        _ inputs: [ArtifactInput],
        leafKey:
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey,
        gateReferenceName: String,
        leafBytes: Data
    ) throws -> [ArtifactInput] {
        let gateKey =
            PrimeNativeNeuralGateHistoricalSemanticArtifactKey
            .gateObservation(.probe)
        let gateBytes = try mutateCanonicalJSONObject(
            input(for: gateKey, in: inputs).bytes
        ) { root in
            var reference = root[gateReferenceName]
                as! [String: Any]
            reference["content_sha256"] =
                PrimeNativeNeuralGateInvariantCodec.sha256(
                    leafBytes
                )
            reference["byte_count"] = leafBytes.count
            root[gateReferenceName] = reference
        }
        return replacing(
            replacing(
                inputs,
                key: leafKey,
                bytes: leafBytes
            ),
            key: gateKey,
            bytes: gateBytes
        )
    }

    private func mutateCanonicalJSONObject(
        _ data: Data,
        mutation: (inout [String: Any]) throws -> Void
    ) throws -> Data {
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        try mutation(&object)
        return try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
    }
}

private enum DecoderTestSupportError: Error {
    case integerOverflow
    case invalidFramedGeometry
}

private typealias FrozenStatisticsEnvelope =
    PrimeNativeNeuralGateHistoricalKeyedThreeSeedStatisticsEnvelope
private typealias Projection =
    PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection
private typealias Decoder =
    PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder
private typealias DecoderError =
    PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderError
private typealias ArtifactInput =
    PrimeNativeNeuralGateHistoricalSemanticArtifactInput
private typealias StreamDecoder =
    PrimeNativeNeuralGateHistoricalInvariantArtifactStreamDecoder

private extension
    PrimeNativeNeuralGateHistoricalKeyedThreeSeedStatisticsEnvelope
{
    static func syntheticForDecoderTest(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole
    ) throws -> Self {
        let floatingBitPattern: UInt64 = 0x3ff0_0000_0000_0000
        let entries = try exactSeedJoin(
            heldout: admittedSeeds.map {
                syntheticHeldoutForDecoderTest(
                    seed: $0.rawValue,
                    floatingBitPattern: floatingBitPattern
                )
            },
            replay: admittedSeeds.map {
                syntheticReplayForDecoderTest(
                    seed: $0.rawValue,
                    floatingBitPattern: floatingBitPattern
                )
            },
            capability: admittedSeeds.map {
                syntheticCapabilityForDecoderTest(
                    seed: $0.rawValue,
                    floatingBitPattern: floatingBitPattern
                )
            }
        )
        let value = Self(
            schemaVersion: 1,
            schemaID: schemaID,
            invocationRole: invocationRole,
            admittedSeeds: admittedSeeds,
            joinPolicyID: joinPolicyID,
            orderedSeedEntries: entries,
            summary: syntheticSummaryForDecoderTest(),
            historicalCriticalLegValues:
                PrimeNativeNeuralGateReplayLegDomain
                .historicalCriticalLegIDs.enumerated().map {
                    PrimeNativeNeuralGateHistoricalCriticalLegCarrierValue(
                        ordinal: $0.offset + 1,
                        legID: $0.element,
                        passed: true
                    )
                },
            reductionApplied: false,
            summaryMaySupplyEvidence: false,
            mechanicsPassAuthorized: false,
            terminalReceiptAuthorized: false,
            sourceBindingV7Issued: false,
            scientificAuthorityAuthorized: false,
            productAuthorityAuthorized: false
        )
        try value.validate()
        return value
    }

    static func syntheticHeldoutForDecoderTest(
        seed: Int,
        floatingBitPattern: UInt64
    ) -> PrimeNativeNeuralGateHistoricalHeldoutSeedStatistics {
        let rows = (0 ..< 288).map { ordinal in
            PrimeNativeNeuralGateHistoricalHeldoutLossRow(
                rowID: "synthetic_\(seed)_\(ordinal)",
                rowSHA256: String(repeating: "a", count: 64),
                selectionSplitID: "heldout",
                targetClass: "synthetic",
                semanticFamily: "synthetic_family",
                targetTokenCount: 1,
                nonPaddingTokenCount: 1,
                crossEntropyBeforeBitPattern: floatingBitPattern,
                crossEntropyAfterBitPattern: floatingBitPattern
            )
        }
        let families = [
            PrimeNativeNeuralGateNamedDoubleBitPattern(
                name: "a_family",
                value: Double(bitPattern: floatingBitPattern)
            ),
            PrimeNativeNeuralGateNamedDoubleBitPattern(
                name: "z_family",
                value: Double(bitPattern: floatingBitPattern)
            ),
        ]
        return PrimeNativeNeuralGateHistoricalHeldoutSeedStatistics(
            seed: seed,
            heldoutRowCount: 288,
            heldoutValidRowCount: 144,
            heldoutRefusalRowCount: 144,
            heldoutTargetTokenCount: 288,
            heldoutValidTargetTokenCount: 144,
            heldoutRefusalTargetTokenCount: 144,
            heldoutEvaluationNonPaddingTokenCount: 288,
            heldoutCrossEntropyBeforeBitPattern: floatingBitPattern,
            heldoutCrossEntropyAfterBitPattern: floatingBitPattern,
            heldoutValidCrossEntropyBeforeBitPattern: floatingBitPattern,
            heldoutValidCrossEntropyAfterBitPattern: floatingBitPattern,
            heldoutRefusalCrossEntropyBeforeBitPattern: floatingBitPattern,
            heldoutRefusalCrossEntropyAfterBitPattern: floatingBitPattern,
            heldoutCrossEntropyStandardErrorBitPattern:
                floatingBitPattern,
            heldoutCrossEntropyStandardErrorMethodID:
                "synthetic_exact",
            heldoutFamilyCrossEntropyBefore: families,
            heldoutFamilyCrossEntropyAfter: families,
            initialLossBitPattern: floatingBitPattern,
            finalLossBitPattern: floatingBitPattern,
            heldoutLossRows: rows
        )
    }

    static func syntheticReplayForDecoderTest(
        seed: Int,
        floatingBitPattern: UInt64
    ) -> PrimeNativeNeuralGateHistoricalFixedPromptSeedReplay {
        let logits = Array(
            repeating: UInt32(0x3f80_0000),
            count: 512
        )
        return PrimeNativeNeuralGateHistoricalFixedPromptSeedReplay(
            seed: seed,
            firstLogitFloatBitPatterns: logits,
            replayLogitFloatBitPatterns: logits,
            maximumLogitDeltaBitPattern: floatingBitPattern,
            firstGreedyTokenID: 1,
            replayGreedyTokenID: 1,
            firstGreedyRunnerUpMarginBitPattern: floatingBitPattern,
            replayGreedyRunnerUpMarginBitPattern: floatingBitPattern,
            greedyTokenExact: true,
            behavioralReplayExact: true,
            firstResultSHA256: String(repeating: "b", count: 64),
            replayResultSHA256: String(repeating: "b", count: 64),
            resultExact: true
        )
    }

    static func syntheticCapabilityForDecoderTest(
        seed: Int,
        floatingBitPattern: UInt64
    ) -> PrimeNativeNeuralGateHistoricalCapabilitySeedObservation {
        let splits = [
            ("validation", 4_096),
            ("combination_holdout", 4_096),
            ("ood", 4_096),
            ("mutation", 4_096),
            ("abstention", 2_048),
        ].map {
            PrimeNativeNeuralGateHistoricalCapabilitySplit(
                splitID: $0.0,
                rowCount: $0.1,
                zeroShotExactAccuracyBitPattern:
                    floatingBitPattern,
                trainedExactAccuracyBitPattern:
                    floatingBitPattern,
                trainedMeanLogProbabilityBitPattern:
                    floatingBitPattern
            )
        }
        let decisions = (0 ..< 2_048).map { ordinal in
            PrimeNativeNeuralGateHistoricalAbstentionDecisionRow(
                rowID: "synthetic_abstention_\(seed)_\(ordinal)",
                corpusRowSHA256: String(repeating: "c", count: 64),
                evaluationRowSHA256: String(repeating: "d", count: 64),
                splitID: "abstention",
                target: "ABSTAIN\n",
                trainedPrediction: "ABSTAIN\n",
                trainedTerminatedByEOS: true,
                trainedTerminationReason: "eos",
                trainedUTF8Valid: true,
                trainedExactMatch: true,
                trainedSemanticVerifierPass: true,
                trainedAbstentionDecision: true
            )
        }
        return PrimeNativeNeuralGateHistoricalCapabilitySeedObservation(
            seed: seed,
            orderedSplitValues: splits,
            requiredAbstentionRowCount: 2_048,
            orderedAbstentionDecisionRows: decisions,
            exactAbstentionDecisionsObserved: true
        )
    }

    static func syntheticSummaryForDecoderTest()
        -> PrimeNativeNeuralGateHistoricalStatisticsSummary
    {
        let mutations = PrimeNativeNeuralGateMutationCatalog
            .historicalEntries.map {
                PrimeNativeNeuralGateHistoricalMutationVerdict(
                    ordinal: Int($0.ordinal),
                    mutationID: $0.mutationID,
                    expectedFailedLegID: $0.expectedFailedLegID,
                    detected: true,
                    fingerprintDiverged: true,
                    restored: true,
                    restoredFingerprintExact: true
                )
            }
        return PrimeNativeNeuralGateHistoricalStatisticsSummary(
            historicalAgreeCount: 10,
            historicalIndependentPassCount: 0,
            historicalOutcome: "ABSTAIN",
            historicalTriadicLabel: "ABSTAIN",
            historicalNextAction: "",
            materialReloadComponents: [],
            historicalMutationOutcome: "ABSTAIN",
            historicalMutationTriadicLabel: "ABSTAIN",
            historicalMutationValues: mutations,
            exactSingletonFailureSetsSatisfied: true,
            sourceDerivedSingletonRegradeOutcome: "GROUNDED"
        )
    }
}

private enum DecoderTestFixtures {
    struct InvariantFixture {
        let records: [Data]
        let bundle: PrimeNativeNeuralGateInvariantBundle
    }

    struct MutationFixture {
        let identities: [String]
        let streams:
            [PrimeNativeNeuralGateHistoricalEvidenceExporter
                .MutationStreamIdentity]
        let fingerprints:
            [PrimeNativeNeuralGateHistoricalEvidenceExporter
                .MutationFingerprintSet]
        let failures:
            [PrimeNativeNeuralGateHistoricalEvidenceExporter
                .MutationObservedFailureSet]
    }

    static let invariant: Result<InvariantFixture, Error> = Result {
        let count =
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1.exactInvariantRecordCount
        let records = (0 ..< count).map {
            Data(String(format: "record_%08d", $0).utf8)
        }
        return InvariantFixture(
            records: records,
            bundle: try PrimeNativeNeuralGateInvariantCodec.makeBundle(
                records: records
            )
        )
    }

    static let alternateInvariant: Result<InvariantFixture, Error> = Result {
        var records = try invariant.get().records
        records[0] = Data("record_00000000_alternate".utf8)
        return InvariantFixture(
            records: records,
            bundle: try PrimeNativeNeuralGateInvariantCodec.makeBundle(
                records: records
            )
        )
    }

    static let probeArtifacts:
        Result<PrimeNativeNeuralGateHistoricalProjectedArtifactSet, Error> =
        Result {
            try makeArtifacts(role: .probe)
        }

    static let verifierArtifacts:
        Result<PrimeNativeNeuralGateHistoricalProjectedArtifactSet, Error> =
        Result {
            try makeArtifacts(role: .verifier)
        }

    static func artifacts(
        for role: PrimeNativeNeuralGateHistoricalArtifactRole
    ) throws -> PrimeNativeNeuralGateHistoricalProjectedArtifactSet {
        switch role {
        case .probe:
            try probeArtifacts.get()
        case .verifier:
            try verifierArtifacts.get()
        }
    }

    static func makeArtifacts(
        role: PrimeNativeNeuralGateHistoricalArtifactRole
    ) throws -> PrimeNativeNeuralGateHistoricalProjectedArtifactSet {
        let invariant = try self.invariant.get()
        let mutationFixture = mutations(
            baselineBundle: invariant.bundle
        )
        let mutation = try Projection.makeMutationObservation(
            orderedMutationIdentities: mutationFixture.identities,
            streamIdentities: mutationFixture.streams,
            fingerprints: mutationFixture.fingerprints,
            observedFailureSets: mutationFixture.failures,
            baselineBundle: invariant.bundle,
            role: role
        )
        let carrierValues = criticalLegCarrierValues()
        let semanticLegs = try Projection.makeCriticalLegs(carrierValues)
        let statistics = try FrozenStatisticsEnvelope
            .syntheticForDecoderTest(invocationRole: role)
        return try Projection.assembleArtifacts(
            invariantBundle: invariant.bundle,
            mutationObservation: mutation,
            criticalLegs: semanticLegs,
            statisticsEnvelope: statistics,
            context: PrimeNativeNeuralGateHistoricalProjectionContext(
                invocationRole: role,
                sourceBytesResolved: .unavailable,
                adaptationProofRecomputed: .unavailable
            )
        )
    }

    static func mutations(
        baselineBundle: PrimeNativeNeuralGateInvariantBundle
    ) -> MutationFixture {
        let catalog = PrimeNativeNeuralGateMutationCatalog
            .historicalEntries
        let baselineSHA = baselineBundle.manifest.globalStreamSHA256
        let baselineObservation = baselineBundle.fingerprintObservation
        let fingerprint = baselineObservation.direct
        let streams = catalog.map { entry in
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .MutationStreamIdentity(
                ordinal: Int(entry.ordinal),
                mutationID: entry.mutationID,
                baselineStreamSHA256: baselineSHA,
                mutatedStreamSHA256:
                    PrimeNativeNeuralGateInvariantCodec.sha256(
                        Data("mutated_\(entry.ordinal)".utf8)
                    ),
                restoredStreamSHA256: baselineSHA
            )
        }
        let fingerprints = zip(catalog, streams).map { entry, stream in
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .MutationFingerprintSet(
                ordinal: Int(entry.ordinal),
                mutationID: entry.mutationID,
                baseline: baselineObservation,
                mutated: PrimeNativeNeuralGateFingerprintObservation(
                    orderedMultisetStreamSHA256:
                        stream.mutatedStreamSHA256,
                    direct: fingerprint,
                    accelerated: fingerprint
                ),
                restored: baselineObservation
            )
        }
        let failures = catalog.map { entry in
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .MutationObservedFailureSet(
                ordinal: Int(entry.ordinal),
                mutationID: entry.mutationID,
                orderedObservedFailedLegIDs: [
                    entry.expectedFailedLegID,
                ]
            )
        }
        return MutationFixture(
            identities: catalog.map(\.mutationID),
            streams: streams,
            fingerprints: fingerprints,
            failures: failures
        )
    }

    static func criticalLegCarrierValues()
        -> [PrimeNativeNeuralGateHistoricalEvidenceExporter
            .CriticalLegValue]
    {
        PrimeNativeNeuralGateReplayLegDomain
            .historicalCriticalLegIDs.enumerated().map {
                PrimeNativeNeuralGateHistoricalEvidenceExporter
                .CriticalLegValue(
                    ordinal: $0.offset + 1,
                    legID: $0.element,
                    passed: true
                )
            }
    }
}
