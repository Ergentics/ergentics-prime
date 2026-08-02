// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import XCTest
@testable import PrimeNativeNeuralGateHistoricalEvidenceExportMechanics
@testable import PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection
@testable import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics

final class
    PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionTests:
    XCTestCase
{
    func testIndependentSeedFamilyPermutationsProduceIdenticalCanonicalBytes()
        throws
    {
        let baseline = try Envelope.syntheticForTesting()
        let permuted = try Envelope.syntheticForTesting(
            heldoutSeedOrder: [3_141, 1_618, 2_718],
            replaySeedOrder: [2_718, 3_141, 1_618],
            capabilitySeedOrder: [1_618, 3_141, 2_718]
        )

        let baselineData = try baseline.canonicalData()
        let permutedData = try permuted.canonicalData()
        XCTAssertEqual(baselineData, permutedData)
        XCTAssertEqual(
            PrimeNativeNeuralGateInvariantCodec.sha256(baselineData),
            PrimeNativeNeuralGateInvariantCodec.sha256(permutedData)
        )
        XCTAssertEqual(
            baseline.orderedSeedEntries.map(\.seed),
            [.seed1618, .seed2718, .seed3141]
        )
        XCTAssertEqual(
            try Envelope.decodeCanonicalTrustedForTesting(
                baselineData
            ),
            baseline
        )
    }

    func testSeedJoinRejectsDuplicateMissingUnknownAndCrossFamilyCoverage() {
        XCTAssertThrowsError(
            try Envelope.syntheticForTesting(
                heldoutSeedOrder: [1_618, 1_618, 2_718, 3_141]
            )
        ) { error in
            XCTAssertEqual(
                error as? ProjectionError,
                .duplicateSeed("heldout", 1_618)
            )
        }

        XCTAssertThrowsError(
            try Envelope.syntheticForTesting(
                heldoutSeedOrder: [1_618, 2_718],
                replaySeedOrder: [1_618, 2_718],
                capabilitySeedOrder: [1_618, 2_718]
            )
        ) { error in
            XCTAssertEqual(
                error as? ProjectionError,
                .missingSeed("all_families", 3_141)
            )
        }

        XCTAssertThrowsError(
            try Envelope.syntheticForTesting(
                heldoutSeedOrder: [1_618, 2_718, 9_999]
            )
        ) { error in
            XCTAssertEqual(
                error as? ProjectionError,
                .unknownSeed("heldout", 9_999)
            )
        }

        XCTAssertThrowsError(
            try Envelope.syntheticForTesting(
                replaySeedOrder: [1_618, 2_718]
            )
        ) { error in
            XCTAssertEqual(
                error as? ProjectionError,
                .crossFamilySeedCoverage
            )
        }
    }

    func testDoubleBitPatternsArePreservedExactly() throws {
        let negativeZero: UInt64 = 0x8000_0000_0000_0000
        let envelope = try Envelope.syntheticForTesting(
            floatingBitPattern: negativeZero
        )
        let first = try XCTUnwrap(
            envelope.orderedSeedEntries.first
        )

        XCTAssertEqual(
            first.heldout.initialLossBitPattern,
            negativeZero
        )
        XCTAssertEqual(
            first.heldout.heldoutLossRows.first?
                .crossEntropyBeforeBitPattern,
            negativeZero
        )
        XCTAssertEqual(
            first.fixedPromptReplay.maximumLogitDeltaBitPattern,
            negativeZero
        )
        XCTAssertEqual(
            first.capability.orderedSplitValues.first?
                .trainedMeanLogProbabilityBitPattern,
            negativeZero
        )
        let decoded = try Envelope.decodeCanonicalTrustedForTesting(
            envelope.canonicalData()
        )
        XCTAssertEqual(decoded, envelope)
    }

    func testCanonicalEncodingRejectsSixteenMiBOverflow() throws {
        let oversized = try Envelope.syntheticForTesting(
            summaryPaddingByteCount:
                Envelope.maximumCanonicalByteCount
        )
        XCTAssertThrowsError(try oversized.canonicalData()) { error in
            guard case let ProjectionError.canonicalJSONTooLarge(count) =
                error
            else {
                return XCTFail("unexpected error: \(error)")
            }
            XCTAssertGreaterThan(
                count,
                Envelope.maximumCanonicalByteCount
            )
        }
    }

    func testTrustedRoundTripRejectsNonCanonicalBytes() throws {
        var data = try Envelope.syntheticForTesting().canonicalData()
        data.append(0x0a)
        XCTAssertThrowsError(
            try Envelope.decodeCanonicalTrustedForTesting(data)
        ) { error in
            XCTAssertEqual(
                error as? ProjectionError,
                .nonCanonicalJSON
            )
        }
    }

    func testTrustedDecodedMutationFailsClosed() throws {
        let canonical = try Envelope.syntheticForTesting().canonicalData()
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        object["mechanics_pass_authorized"] = true
        let mutated = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertThrowsError(
            try Envelope.decodeCanonicalTrustedForTesting(mutated)
        ) { error in
            XCTAssertEqual(
                error as? ProjectionError,
                .invalidStatisticsEnvelope("shape_or_authority")
            )
        }
    }

    func testEnvelopeRemainsNonAuthorizingAndRetainsAllCarrierShapes()
        throws
    {
        let envelope = try Envelope.syntheticForTesting(
            invocationRole: .verifier
        )
        XCTAssertEqual(envelope.invocationRole, .verifier)
        XCTAssertEqual(envelope.orderedSeedEntries.count, 3)
        for entry in envelope.orderedSeedEntries {
            XCTAssertEqual(entry.heldout.heldoutLossRows.count, 288)
            XCTAssertEqual(
                entry.fixedPromptReplay
                    .firstLogitFloatBitPatterns.count,
                512
            )
            XCTAssertEqual(
                entry.fixedPromptReplay
                    .replayLogitFloatBitPatterns.count,
                512
            )
            XCTAssertEqual(
                entry.capability.orderedSplitValues.count,
                5
            )
            XCTAssertEqual(
                entry.capability.orderedAbstentionDecisionRows.count,
                2_048
            )
        }
        XCTAssertEqual(
            envelope.summary.historicalMutationValues.count,
            46
        )
        XCTAssertEqual(envelope.historicalCriticalLegValues.count, 10)
        XCTAssertFalse(envelope.reductionApplied)
        XCTAssertFalse(envelope.summaryMaySupplyEvidence)
        XCTAssertFalse(envelope.mechanicsPassAuthorized)
        XCTAssertFalse(envelope.terminalReceiptAuthorized)
        XCTAssertFalse(envelope.sourceBindingV7Issued)
        XCTAssertFalse(envelope.scientificAuthorityAuthorized)
        XCTAssertFalse(envelope.productAuthorityAuthorized)
    }

    func testEveryCanonicalJSONArtifactBindsEmbeddedSchemaID() throws {
        let namespace =
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1
        let jsonKeys =
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .allKeys(for: .probe).filter { key in
                (try? namespace.spec(for: key).encoding)
                    == .canonicalJSON
            }
        XCTAssertEqual(jsonKeys.count, 6)

        for key in jsonKeys {
            let spec = try namespace.spec(for: key)
            let matching = try canonicalSchemaOnlyJSON(spec.schemaID)
            XCTAssertNoThrow(
                try PrimeNativeNeuralGateHistoricalProjectedArtifact(
                    specification: spec,
                    bytes: matching
                )
            )
            XCTAssertThrowsError(
                try PrimeNativeNeuralGateHistoricalProjectedArtifact(
                    specification: spec,
                    bytes: try canonicalSchemaOnlyJSON(
                        "prime_stage_b_intentional_schema_mismatch_v1"
                    )
                )
            )
        }
    }

    func testArtifactSetRequiresExactNamespaceOrder() throws {
        let namespace =
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1
        let artifacts = try
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .allKeys(for: .probe).map { key in
                let spec = try namespace.spec(for: key)
                let bytes = spec.encoding == .canonicalJSON
                    ? try canonicalSchemaOnlyJSON(spec.schemaID)
                    : Data([0x01])
                return try
                    PrimeNativeNeuralGateHistoricalProjectedArtifact(
                        specification: spec,
                        bytes: bytes
                    )
            }
        let artifactSet = try
            PrimeNativeNeuralGateHistoricalProjectedArtifactSet(
                invocationRole: .probe,
                orderedArtifacts: artifacts
            )
        XCTAssertEqual(artifactSet.orderedArtifacts.count, 22)
        XCTAssertFalse(artifactSet.artifactWritePerformed)
        XCTAssertFalse(artifactSet.evidencePublished)
        XCTAssertFalse(artifactSet.durablePublicationObserved)
        XCTAssertFalse(artifactSet.mechanicsPassAuthorized)
        XCTAssertFalse(artifactSet.terminalReceiptAuthorized)
        XCTAssertFalse(artifactSet.sourceBindingV7Issued)

        var reordered = artifacts
        reordered.swapAt(0, 1)
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalProjectedArtifactSet(
                invocationRole: .probe,
                orderedArtifacts: reordered
            )
        )

        let original = artifacts[0]
        let spec = original.specification
        let samePathWrongSpec = PrimeNativeNeuralGateArtifactSpec(
            schemaID: spec.schemaID,
            schemaVersion: spec.schemaVersion,
            relativePath: spec.relativePath,
            maximumByteCount: spec.maximumByteCount + 1,
            encoding: spec.encoding,
            decoderMode: spec.decoderMode,
            purpose: spec.purpose,
            mode: spec.mode,
            owner: spec.owner,
            allowedReaders: spec.allowedReaders,
            transportCanAuthorizeMechanicsPass:
                spec.transportCanAuthorizeMechanicsPass,
            transportCanAuthorizeCapability:
                spec.transportCanAuthorizeCapability,
            transportCanAuthorizeReceipt:
                spec.transportCanAuthorizeReceipt
        )
        var wrongSpecifications = artifacts
        wrongSpecifications[0] = try
            PrimeNativeNeuralGateHistoricalProjectedArtifact(
                specification: samePathWrongSpec,
                bytes: original.bytes
            )
        XCTAssertEqual(
            wrongSpecifications.map(\.relativePath),
            artifacts.map(\.relativePath)
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalProjectedArtifactSet(
                invocationRole: .probe,
                orderedArtifacts: wrongSpecifications
            )
        )
    }

    func testInvariantMechanicsSeamAcceptsExactAndRejectsDeepDrift()
        throws
    {
        let fixture = try ProjectionTestFixtures.invariant.get()
        XCTAssertEqual(
            try Projection.verifyInvariantEvidence(
                records: fixture.records,
                asciiFlags: fixture.asciiFlags,
                baselineBundle: fixture.bundle
            ),
            fixture.bundle
        )

        var wrongFlags = fixture.asciiFlags
        wrongFlags[0].toggle()
        XCTAssertThrowsError(
            try Projection.verifyInvariantEvidence(
                records: fixture.records,
                asciiFlags: wrongFlags,
                baselineBundle: fixture.bundle
            )
        ) { error in
            XCTAssertEqual(
                error as? ProjectionError,
                .invalidInvariantEvidence(
                    "record_or_ascii_coverage"
                )
            )
        }

        XCTAssertThrowsError(
            try Projection.verifyInvariantEvidence(
                records: Array(fixture.records.dropLast()),
                asciiFlags: Array(fixture.asciiFlags.dropLast()),
                baselineBundle: fixture.bundle
            )
        )

        var changedRecords = fixture.records
        changedRecords[0] = Data("changed_record".utf8)
        XCTAssertThrowsError(
            try Projection.verifyInvariantEvidence(
                records: changedRecords,
                asciiFlags: fixture.asciiFlags,
                baselineBundle: fixture.bundle
            )
        ) { error in
            XCTAssertEqual(
                error as? ProjectionError,
                .invalidInvariantEvidence("bundle_recomputation")
            )
        }
    }

    func testMutationMechanicsSeamJoinsExactlyAndFailsClosed()
        throws
    {
        let invariant = try ProjectionTestFixtures.invariant.get()
        let fixture = ProjectionTestFixtures.mutations(
            baselineBundle: invariant.bundle
        )
        let valid = try Projection.makeMutationObservation(
            orderedMutationIdentities: fixture.identities,
            streamIdentities: fixture.streams,
            fingerprints: fixture.fingerprints,
            observedFailureSets: fixture.failures,
            baselineBundle: invariant.bundle,
            role: .probe
        )
        XCTAssertEqual(valid.observations.count, 46)
        XCTAssertTrue(valid.observations.allSatisfy {
            $0.allowedFailedLegIDs == [$0.expectedFailedLegID]
                && $0.mutationExecutionObserved == .unavailable
                && $0.independentDetectionObserved == .unavailable
        })

        let rotatedFingerprints =
            Array(fixture.fingerprints.dropFirst(7))
            + Array(fixture.fingerprints.prefix(7))
        let interleavedFailures =
            fixture.failures.enumerated().filter {
                $0.offset.isMultiple(of: 2)
            }.map { $0.element }
            + fixture.failures.enumerated().filter {
                !$0.offset.isMultiple(of: 2)
            }.map { $0.element }
        XCTAssertEqual(
            try Projection.makeMutationObservation(
                orderedMutationIdentities: fixture.identities,
                streamIdentities: Array(fixture.streams.reversed()),
                fingerprints: rotatedFingerprints,
                observedFailureSets: interleavedFailures,
                baselineBundle: invariant.bundle,
                role: .probe
            ),
            valid
        )

        var crossFamilyFingerprints = fixture.fingerprints
        let firstCrossFamily = crossFamilyFingerprints[0]
        let secondCrossFamily = crossFamilyFingerprints[1]
        crossFamilyFingerprints[0] =
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .MutationFingerprintSet(
                ordinal: firstCrossFamily.ordinal,
                mutationID: firstCrossFamily.mutationID,
                baseline: firstCrossFamily.baseline,
                mutated: secondCrossFamily.mutated,
                restored: firstCrossFamily.restored
            )
        crossFamilyFingerprints[1] =
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .MutationFingerprintSet(
                ordinal: secondCrossFamily.ordinal,
                mutationID: secondCrossFamily.mutationID,
                baseline: secondCrossFamily.baseline,
                mutated: firstCrossFamily.mutated,
                restored: secondCrossFamily.restored
            )
        XCTAssertThrowsError(
            try Projection.makeMutationObservation(
                orderedMutationIdentities: fixture.identities,
                streamIdentities: fixture.streams,
                fingerprints: crossFamilyFingerprints,
                observedFailureSets: fixture.failures,
                baselineBundle: invariant.bundle,
                role: .probe
            )
        )

        var duplicateStreams = fixture.streams
        duplicateStreams[1] = duplicateStreams[0]
        XCTAssertThrowsError(
            try Projection.makeMutationObservation(
                orderedMutationIdentities: fixture.identities,
                streamIdentities: duplicateStreams,
                fingerprints: fixture.fingerprints,
                observedFailureSets: fixture.failures,
                baselineBundle: invariant.bundle,
                role: .probe
            )
        )

        XCTAssertThrowsError(
            try Projection.makeMutationObservation(
                orderedMutationIdentities: fixture.identities,
                streamIdentities: Array(fixture.streams.dropLast()),
                fingerprints: fixture.fingerprints,
                observedFailureSets: fixture.failures,
                baselineBundle: invariant.bundle,
                role: .probe
            )
        )

        var wrongIdentityStreams = fixture.streams
        let first = wrongIdentityStreams[0]
        wrongIdentityStreams[0] =
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .MutationStreamIdentity(
                ordinal: first.ordinal,
                mutationID: "wrong_identity",
                baselineStreamSHA256:
                    first.baselineStreamSHA256,
                mutatedStreamSHA256:
                    first.mutatedStreamSHA256,
                restoredStreamSHA256:
                    first.restoredStreamSHA256
            )
        XCTAssertThrowsError(
            try Projection.makeMutationObservation(
                orderedMutationIdentities: fixture.identities,
                streamIdentities: wrongIdentityStreams,
                fingerprints: fixture.fingerprints,
                observedFailureSets: fixture.failures,
                baselineBundle: invariant.bundle,
                role: .probe
            )
        )

        var mismatchedSHAStreams = fixture.streams
        mismatchedSHAStreams[0] =
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .MutationStreamIdentity(
                ordinal: first.ordinal,
                mutationID: first.mutationID,
                baselineStreamSHA256:
                    String(repeating: "f", count: 64),
                mutatedStreamSHA256:
                    first.mutatedStreamSHA256,
                restoredStreamSHA256:
                    first.restoredStreamSHA256
            )
        XCTAssertThrowsError(
            try Projection.makeMutationObservation(
                orderedMutationIdentities: fixture.identities,
                streamIdentities: mismatchedSHAStreams,
                fingerprints: fixture.fingerprints,
                observedFailureSets: fixture.failures,
                baselineBundle: invariant.bundle,
                role: .probe
            )
        )

        var mismatchedRestoredStreams = fixture.streams
        mismatchedRestoredStreams[0] =
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .MutationStreamIdentity(
                ordinal: first.ordinal,
                mutationID: first.mutationID,
                baselineStreamSHA256:
                    first.baselineStreamSHA256,
                mutatedStreamSHA256:
                    first.mutatedStreamSHA256,
                restoredStreamSHA256:
                    String(repeating: "e", count: 64)
            )
        XCTAssertThrowsError(
            try Projection.makeMutationObservation(
                orderedMutationIdentities: fixture.identities,
                streamIdentities: mismatchedRestoredStreams,
                fingerprints: fixture.fingerprints,
                observedFailureSets: fixture.failures,
                baselineBundle: invariant.bundle,
                role: .probe
            )
        )

        var noncanonicalFingerprints = fixture.fingerprints
        let firstFingerprints = noncanonicalFingerprints[0]
        noncanonicalFingerprints[0] =
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .MutationFingerprintSet(
                ordinal: firstFingerprints.ordinal,
                mutationID: firstFingerprints.mutationID,
                baseline: try ProjectionTestFixtures
                    .mutatingCacheKey(
                        firstFingerprints.baseline
                    ),
                mutated: firstFingerprints.mutated,
                restored: firstFingerprints.restored
            )
        XCTAssertThrowsError(
            try Projection.makeMutationObservation(
                orderedMutationIdentities: fixture.identities,
                streamIdentities: fixture.streams,
                fingerprints: noncanonicalFingerprints,
                observedFailureSets: fixture.failures,
                baselineBundle: invariant.bundle,
                role: .probe
            )
        )
    }

    func testCriticalLegSeamRetainsCarrierBoolAndRejectsDrift()
        throws
    {
        let values = ProjectionTestFixtures.criticalLegs(
            firstPassed: false
        )
        let semantic = try Projection.makeCriticalLegs(values)
        XCTAssertEqual(semantic.count, 10)
        XCTAssertEqual(
            semantic[0].detail,
            "source_derived_historical_carrier_passed_false"
        )
        XCTAssertEqual(
            semantic[1].detail,
            "source_derived_historical_carrier_passed_true"
        )
        XCTAssertTrue(semantic.allSatisfy {
            $0.passed == .unavailable && $0.evidence.isEmpty
        })

        var duplicate = values
        duplicate[1] = duplicate[0]
        XCTAssertThrowsError(try Projection.makeCriticalLegs(duplicate))
        XCTAssertThrowsError(
            try Projection.makeCriticalLegs(Array(values.dropLast()))
        )

        var wrongIdentity = values
        wrongIdentity[0] =
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .CriticalLegValue(
                ordinal: 1,
                legID: "wrong_leg",
                passed: false
            )
        XCTAssertThrowsError(
            try Projection.makeCriticalLegs(wrongIdentity)
        )
    }

    func testAssemblySeamBuildsExactNonAuthorizingArtifactsForBothRoles()
        throws
    {
        let invariant = try ProjectionTestFixtures.invariant.get()
        let mutationFixture = ProjectionTestFixtures.mutations(
            baselineBundle: invariant.bundle
        )
        let carrierLegs = ProjectionTestFixtures.criticalLegs()
        let criticalLegs = try Projection.makeCriticalLegs(carrierLegs)
        let namespace =
            PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
            .frozenV1

        for role in PrimeNativeNeuralGateHistoricalArtifactRole.allCases {
            let mutation = try Projection.makeMutationObservation(
                orderedMutationIdentities: mutationFixture.identities,
                streamIdentities: mutationFixture.streams,
                fingerprints: mutationFixture.fingerprints,
                observedFailureSets: mutationFixture.failures,
                baselineBundle: invariant.bundle,
                role: role
            )
            let envelope = try Envelope.syntheticForTesting(
                invocationRole: role
            )
            let context = PrimeNativeNeuralGateHistoricalProjectionContext(
                invocationRole: role,
                sourceBytesResolved: .unavailable,
                adaptationProofRecomputed: .unavailable
            )
            let artifacts = try Projection.assembleArtifacts(
                invariantBundle: invariant.bundle,
                mutationObservation: mutation,
                criticalLegs: criticalLegs,
                statisticsEnvelope: envelope,
                context: context
            )
            let expectedSpecs = try
                PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract
                .allKeys(for: role).map {
                    try namespace.spec(for: $0)
                }
            XCTAssertEqual(
                artifacts.orderedArtifacts.map(\.specification),
                expectedSpecs
            )
            XCTAssertEqual(artifacts.orderedArtifacts.count, 22)
            XCTAssertTrue(artifacts.orderedArtifacts.allSatisfy {
                $0.relativePath.hasPrefix(
                    "neural-gate-replay/historical/\(role.rawValue)/"
                )
                    && $0.descriptorContentVerified == .unavailable
                    && $0.durablePublicationObserved == .unavailable
                    && !$0.mechanicsPassAuthorized
                    && !$0.terminalReceiptAuthorized
                    && !$0.sourceBindingV7Issued
            })
            XCTAssertFalse(artifacts.artifactWritePerformed)
            XCTAssertFalse(artifacts.evidencePublished)
            XCTAssertFalse(artifacts.mechanicsPassAuthorized)
            XCTAssertFalse(artifacts.terminalReceiptAuthorized)
            XCTAssertFalse(artifacts.scientificAuthorityAuthorized)
            XCTAssertFalse(artifacts.productAuthorityAuthorized)

            XCTAssertEqual(
                try artifacts.artifact(
                    for: .invariantRecordsGlobal(role)
                ).bytes,
                invariant.bundle.globalStream
            )
            for index in 0 ..< 15 {
                XCTAssertEqual(
                    try artifacts.artifact(
                        for: .invariantChunk(
                            role,
                            UInt32(index)
                        )
                    ).bytes,
                    invariant.bundle.chunkStreams[index]
                )
            }
            for artifact in artifacts.orderedArtifacts
            where artifact.specification.encoding == .canonicalJSON {
                let object = try XCTUnwrap(
                    JSONSerialization.jsonObject(
                        with: artifact.bytes
                    ) as? [String: Any]
                )
                XCTAssertEqual(
                    object["schema_id"] as? String,
                    artifact.schemaID
                )
            }
            let gateBytes = try artifacts.artifact(
                for: .gateObservation(role)
            ).bytes
            let gate = try XCTUnwrap(
                JSONSerialization.jsonObject(with: gateBytes)
                    as? [String: Any]
            )
            XCTAssertEqual(
                gate["mechanics_outcome"] as? String,
                "ABSTAIN"
            )
            XCTAssertEqual(
                gate["mechanics_pass_authorized"] as? Bool,
                false
            )
        }
    }

    func testAssemblySeamRejectsRoleLegAndChunkGeometryDrift()
        throws
    {
        let invariant = try ProjectionTestFixtures.invariant.get()
        let mutationFixture = ProjectionTestFixtures.mutations(
            baselineBundle: invariant.bundle
        )
        let mutation = try Projection.makeMutationObservation(
            orderedMutationIdentities: mutationFixture.identities,
            streamIdentities: mutationFixture.streams,
            fingerprints: mutationFixture.fingerprints,
            observedFailureSets: mutationFixture.failures,
            baselineBundle: invariant.bundle,
            role: .probe
        )
        let allPassed = ProjectionTestFixtures.criticalLegs()
        let semanticLegs = try Projection.makeCriticalLegs(allPassed)
        let envelope = try Envelope.syntheticForTesting(
            invocationRole: .probe
        )
        let verifierContext =
            PrimeNativeNeuralGateHistoricalProjectionContext(
                invocationRole: .verifier,
                sourceBytesResolved: .unavailable,
                adaptationProofRecomputed: .unavailable
            )
        XCTAssertThrowsError(
            try Projection.assembleArtifacts(
                invariantBundle: invariant.bundle,
                mutationObservation: mutation,
                criticalLegs: semanticLegs,
                statisticsEnvelope: envelope,
                context: verifierContext
            )
        )

        let falseFirstLegs = try Projection.makeCriticalLegs(
            ProjectionTestFixtures.criticalLegs(firstPassed: false)
        )
        let probeContext = PrimeNativeNeuralGateHistoricalProjectionContext(
            invocationRole: .probe,
            sourceBytesResolved: .unavailable,
            adaptationProofRecomputed: .unavailable
        )
        XCTAssertThrowsError(
            try Projection.assembleArtifacts(
                invariantBundle: invariant.bundle,
                mutationObservation: mutation,
                criticalLegs: falseFirstLegs,
                statisticsEnvelope: envelope,
                context: probeContext
            )
        )

        let shortBundle = try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records: Array(invariant.records.prefix(4_096))
            )
        XCTAssertThrowsError(
            try Projection.assembleArtifacts(
                invariantBundle: shortBundle,
                mutationObservation: mutation,
                criticalLegs: semanticLegs,
                statisticsEnvelope: envelope,
                context: probeContext
            )
        )

        var alternateRecords = invariant.records
        alternateRecords[0] = Data("alternate_record".utf8)
        let alternateBundle = try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: alternateRecords)
        let alternateMutationFixture = ProjectionTestFixtures.mutations(
            baselineBundle: alternateBundle
        )
        let alternateMutation = try Projection.makeMutationObservation(
            orderedMutationIdentities:
                alternateMutationFixture.identities,
            streamIdentities: alternateMutationFixture.streams,
            fingerprints: alternateMutationFixture.fingerprints,
            observedFailureSets: alternateMutationFixture.failures,
            baselineBundle: alternateBundle,
            role: .probe
        )
        XCTAssertThrowsError(
            try Projection.assembleArtifacts(
                invariantBundle: invariant.bundle,
                mutationObservation: alternateMutation,
                criticalLegs: semanticLegs,
                statisticsEnvelope: envelope,
                context: probeContext
            )
        )
    }

    func testTopLevelProjectionIsCompileBoundButNotExecutedBySyntheticTests() {
        let function:
            (
                PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,
                PrimeNativeNeuralGateHistoricalProjectionContext
            ) throws
                -> PrimeNativeNeuralGateHistoricalProjectedArtifactSet =
            PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection
            .project
        _ = function
    }

    private func canonicalSchemaOnlyJSON(
        _ schemaID: String
    ) throws -> Data {
        struct SchemaOnly: Encodable {
            let schemaID: String

            private enum CodingKeys: String, CodingKey {
                case schemaID = "schema_id"
            }
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        return try encoder.encode(SchemaOnly(schemaID: schemaID))
    }

    private typealias Envelope =
        PrimeNativeNeuralGateHistoricalKeyedThreeSeedStatisticsEnvelope
    private typealias ProjectionError =
        PrimeNativeNeuralGateHistoricalProjectionError
    private typealias Projection =
        PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection
}

private extension
    PrimeNativeNeuralGateHistoricalKeyedThreeSeedStatisticsEnvelope
{
    static func syntheticForTesting(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole = .probe,
        heldoutSeedOrder: [Int] = [1_618, 2_718, 3_141],
        replaySeedOrder: [Int] = [1_618, 2_718, 3_141],
        capabilitySeedOrder: [Int] = [1_618, 2_718, 3_141],
        floatingBitPattern: UInt64 = 0x3ff0_0000_0000_0000,
        summaryPaddingByteCount: Int = 0
    ) throws -> Self {
        let entries = try exactSeedJoin(
            heldout: heldoutSeedOrder.map {
                syntheticHeldout(
                    seed: $0,
                    floatingBitPattern: floatingBitPattern
                )
            },
            replay: replaySeedOrder.map {
                syntheticReplay(
                    seed: $0,
                    floatingBitPattern: floatingBitPattern
                )
            },
            capability: capabilitySeedOrder.map {
                syntheticCapability(
                    seed: $0,
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
            summary: syntheticSummary(
                paddingByteCount: summaryPaddingByteCount
            ),
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

    static func syntheticHeldout(
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
        let familyValues = [
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
            heldoutFamilyCrossEntropyBefore: familyValues,
            heldoutFamilyCrossEntropyAfter: familyValues,
            initialLossBitPattern: floatingBitPattern,
            finalLossBitPattern: floatingBitPattern,
            heldoutLossRows: rows
        )
    }

    static func syntheticReplay(
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

    static func syntheticCapability(
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
        let abstentionRows = (0 ..< 2_048).map { ordinal in
            PrimeNativeNeuralGateHistoricalAbstentionDecisionRow(
                rowID: "synthetic_abstention_\(seed)_\(ordinal)",
                corpusRowSHA256: String(repeating: "c", count: 64),
                evaluationRowSHA256:
                    String(repeating: "d", count: 64),
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
            orderedAbstentionDecisionRows: abstentionRows,
            exactAbstentionDecisionsObserved: true
        )
    }

    static func syntheticSummary(
        paddingByteCount: Int
    ) -> PrimeNativeNeuralGateHistoricalStatisticsSummary {
        let mutationValues =
            PrimeNativeNeuralGateMutationCatalog.historicalEntries.map {
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
            historicalNextAction:
                String(repeating: "x", count: paddingByteCount),
            materialReloadComponents: [],
            historicalMutationOutcome: "ABSTAIN",
            historicalMutationTriadicLabel: "ABSTAIN",
            historicalMutationValues: mutationValues,
            exactSingletonFailureSetsSatisfied: true,
            sourceDerivedSingletonRegradeOutcome: "GROUNDED"
        )
    }
}

private enum ProjectionTestFixtures {
    struct InvariantFixture {
        let records: [Data]
        let asciiFlags: [Bool]
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
            asciiFlags: Array(repeating: true, count: count),
            bundle: try PrimeNativeNeuralGateInvariantCodec.makeBundle(
                records: records
            )
        )
    }

    static func mutations(
        baselineBundle: PrimeNativeNeuralGateInvariantBundle
    ) -> MutationFixture {
        let catalog = PrimeNativeNeuralGateMutationCatalog
            .historicalEntries
        let baselineStreamSHA256 =
            baselineBundle.manifest.globalStreamSHA256
        let baselineObservation =
            baselineBundle.fingerprintObservation
        let fingerprint = baselineObservation.direct
        let streams = catalog.map { entry in
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .MutationStreamIdentity(
                ordinal: Int(entry.ordinal),
                mutationID: entry.mutationID,
                baselineStreamSHA256:
                    baselineStreamSHA256,
                mutatedStreamSHA256:
                    streamSHA("mutated", entry.ordinal),
                restoredStreamSHA256:
                    baselineStreamSHA256
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

    static func criticalLegs(
        firstPassed: Bool = true
    ) -> [PrimeNativeNeuralGateHistoricalEvidenceExporter.CriticalLegValue] {
        PrimeNativeNeuralGateReplayLegDomain
            .historicalCriticalLegIDs.enumerated().map {
                PrimeNativeNeuralGateHistoricalEvidenceExporter
                .CriticalLegValue(
                    ordinal: $0.offset + 1,
                    legID: $0.element,
                    passed: $0.offset == 0 ? firstPassed : true
                )
            }
    }

    static func mutatingCacheKey(
        _ observation: PrimeNativeNeuralGateFingerprintObservation
    ) throws -> PrimeNativeNeuralGateFingerprintObservation {
        let encoded = try JSONEncoder().encode(observation)
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded)
                as? [String: Any]
        )
        object["cache_key"] = "intentionally_noncanonical_cache_key"
        let mutated = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        return try JSONDecoder().decode(
            PrimeNativeNeuralGateFingerprintObservation.self,
            from: mutated
        )
    }

    private static func streamSHA(
        _ domain: String,
        _ ordinal: UInt32
    ) -> String {
        PrimeNativeNeuralGateInvariantCodec.sha256(
            Data("\(domain)_\(ordinal)".utf8)
        )
    }
}
