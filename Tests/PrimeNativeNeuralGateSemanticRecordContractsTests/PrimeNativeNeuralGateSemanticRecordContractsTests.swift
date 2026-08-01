import Foundation
import XCTest
@testable import PrimeNativeNeuralGateSemanticRecordContracts

final class PrimeNativeNeuralGateSemanticRecordContractsTests:
    XCTestCase
{
    func testFrozenOverlayPreservesV4AndCatalogMappings()
        throws
    {
        let contract =
            PrimeNativeNeuralGateSemanticRecordContract
            .frozenV1
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_semantic_record_schema_contract_v1"
        )
        XCTAssertEqual(
            contract.preservedArtifactOutputContractSHA256,
            "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1"
        )
        XCTAssertEqual(
            contract.mutationArtifactSchemas.map(
                \.exactCatalogCount
            ),
            [46, 15]
        )
        XCTAssertEqual(contract.semanticSchemaIDs.count, 12)
        XCTAssertTrue(contract.aggregateValuesEncodableOnly)
        XCTAssertTrue(contract.v4PreservedUnchanged)
        XCTAssertFalse(contract.sourcePinningObserved)
        XCTAssertFalse(contract.executionObserved)
        XCTAssertFalse(contract.durablePublicationObserved)
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(contract.sourceBindingV7Issued)
    }

    func testFrozenContractContentSHA256IsPinned()
        throws
    {
        XCTAssertEqual(
            try PrimeNativeNeuralGateSemanticRecordContract
                .frozenV1.contentSHA256(),
            "67451098c4c486cd6a2d1701190c7ba3129d48f47956dc5c674295053f47cf9a"
        )
    }

    func testTriStateWireValuesNeverCollapseUnavailableIntoFalse()
        throws
    {
        let encoder = JSONEncoder()
        let unavailable = try encoder.encode(
            PrimeNativeNeuralGateSemanticObservationState
                .unavailable
        )
        let observedFalse = try encoder.encode(
            PrimeNativeNeuralGateSemanticObservationState
                .observedFalse
        )
        let observedTrue = try encoder.encode(
            PrimeNativeNeuralGateSemanticObservationState
                .observedTrue
        )
        XCTAssertEqual(
            String(decoding: unavailable, as: UTF8.self),
            "\"unavailable\""
        )
        XCTAssertEqual(
            String(decoding: observedFalse, as: UTF8.self),
            "\"observed_false\""
        )
        XCTAssertEqual(
            String(decoding: observedTrue, as: UTF8.self),
            "\"observed_true\""
        )
        XCTAssertNotEqual(unavailable, observedFalse)
        XCTAssertFalse(
            String(decoding: unavailable, as: UTF8.self)
                .contains("null")
        )
    }

    func testHistoricalMaterialContractFreezesAllElevenPins()
        throws
    {
        let contract =
            PrimeNativeNeuralGateHistoricalMaterialIdentityContract
            .frozenV1
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.sourcePins.count, 11)
        XCTAssertEqual(
            contract.sourcePins.map(\.byteCount).reduce(0, +),
            1_232_537
        )
        XCTAssertEqual(
            contract.sourcePins.first?.sha256,
            "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6"
        )
        XCTAssertEqual(
            contract.sourcePins.last?.sha256,
            "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
        )
        XCTAssertFalse(contract.sourceBytesResolvedHere)
        XCTAssertFalse(contract.donorBytesExecutedHere)
        XCTAssertFalse(contract.historicalEvidenceReconstructed)
    }

    func testMLXObservationIsDigestOnlyAndBounded()
        throws
    {
        let contract =
            PrimeNativeNeuralGateMLXObservationContract
            .frozenV1
        XCTAssertNoThrow(try contract.validate())
        let observation = try
            PrimeNativeNeuralGateMLXLogSoftmaxDigestObservation(
                evaluationSeed: .seed1618,
                inputDictionarySHA256: sha("a"),
                vectorCount: 65_536,
                outputBitPatternSHA256: sha("b"),
                sourcePinningObserved: .unavailable,
                recomputationObserved: .unavailable,
                fullFixtureCoverageObserved: .unavailable,
                durableArtifactObserved: .unavailable,
                modelExecutionObserved: .unavailable,
                metalExecutionAuthorityObserved: .unavailable
            )
        XCTAssertNoThrow(try observation.validate())
        XCTAssertEqual(observation.vocabularyCount, 512)
        XCTAssertEqual(observation.axis, -1)
        XCTAssertEqual(
            observation.relativePath,
            "neural-gate-replay/corrected/replicates/0000000000001618/mlx-logsoftmax-observation.v1.json"
        )
        XCTAssertFalse(observation.processRecordPublished)
        XCTAssertFalse(observation.mechanicsPassAuthorized)
        let encoded = try JSONEncoder().encode(observation)
        let text = String(decoding: encoded, as: UTF8.self)
        XCTAssertFalse(text.contains("log_probability_vectors"))
        XCTAssertFalse(text.contains("null"))
    }

    func testMLXObservationRejectsMalformedDigestAndOverflow()
    {
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateMLXLogSoftmaxDigestObservation(
                evaluationSeed: .seed2718,
                inputDictionarySHA256: sha("A"),
                vectorCount: 1,
                outputBitPatternSHA256: sha("b"),
                sourcePinningObserved: .unavailable,
                recomputationObserved: .unavailable,
                fullFixtureCoverageObserved: .unavailable,
                durableArtifactObserved: .unavailable,
                modelExecutionObserved: .unavailable,
                metalExecutionAuthorityObserved: .unavailable
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateMLXLogSoftmaxDigestObservation(
                evaluationSeed: .seed3141,
                inputDictionarySHA256: sha("a"),
                vectorCount: 65_537,
                outputBitPatternSHA256: sha("b"),
                sourcePinningObserved: .unavailable,
                recomputationObserved: .unavailable,
                fullFixtureCoverageObserved: .unavailable,
                durableArtifactObserved: .unavailable,
                modelExecutionObserved: .unavailable,
                metalExecutionAuthorityObserved: .unavailable
            )
        )
    }

    func testStatisticsVerdictKeepsUnknownLegsAtAbstain()
        throws
    {
        let weighted = try
            PrimeNativeNeuralGateWeightedStatisticsObservation(
                rowCount: 1,
                totalTargetTokenCount: 1,
                weightedMeanBefore: 1,
                weightedMeanAfter: 0.5,
                effectiveRows: 1,
                unbiasedVarianceDenominator: 0,
                weightedVarianceAfter: 0,
                standardErrorAfter: 0,
                recomputationObserved: .unavailable
            )
        let margin = try
            PrimeNativeNeuralGateFixedPromptMarginObservation(
                firstGreedyTokenID: 1,
                replayGreedyTokenID: 1,
                firstRunnerUpMargin: 1,
                replayRunnerUpMargin: 1,
                maximumAbsoluteLogitDelta: 0,
                greedyTokenStable: .unavailable,
                behavioralReplayExact: .unavailable,
                bitwiseReplayExact: .unavailable
            )
        let splits = try
            PrimeNativeNeuralGateSemanticCapabilitySplit
            .allCases.map {
                try PrimeNativeNeuralGateCapabilitySplitObservation(
                    split: $0,
                    zeroShotExactAccuracy: 0,
                    correctedExactAccuracy: 0,
                    thresholdSatisfied: .unavailable
                )
            }
        let capability = try
            PrimeNativeNeuralGateCapabilityObservation(
                splits: splits,
                sourceBoundRowIdentityAndCoverage: .unavailable,
                thresholdsSatisfied: .unavailable,
                modelCapability: .unavailable
            )
        let legs = try makeLegs(passed: .unavailable)
        let verdict = try
            PrimeNativeNeuralGateStatisticsVerdictObservation(
                arm: .correctedFixedCapEOS,
                weightedStatistics: weighted,
                fixedPromptMargin: margin,
                capability: capability,
                criticalLegs: legs,
                mutationSweepSatisfied: .unavailable,
                sourceBoundCriticalLegEvidence: .unavailable,
                distinctImplementationFamiliesEstablished:
                    .unavailable,
                agentContractKitFourTierAuditPerformed:
                    .unavailable
            )
        XCTAssertNoThrow(try verdict.validate())
        XCTAssertEqual(verdict.passingLegCount, 0)
        XCTAssertEqual(verdict.countDerivedLabel, "oracleDerived(0)")
        XCTAssertEqual(verdict.mechanicsOutcome, .abstain)
        XCTAssertEqual(
            verdict.distinctImplementationFamiliesEstablished,
            .unavailable
        )
        XCTAssertEqual(
            verdict.agentContractKitFourTierAuditPerformed,
            .unavailable
        )
        XCTAssertFalse(verdict.mechanicsPassAuthorized)
    }

    func testFixedPromptStatesCannotContradictDerivedPredicates()
        throws
    {
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateFixedPromptMarginObservation(
                firstGreedyTokenID: 1,
                replayGreedyTokenID: 1,
                firstRunnerUpMargin: 1,
                replayRunnerUpMargin: 1,
                maximumAbsoluteLogitDelta: 0.25,
                greedyTokenStable: .observedTrue,
                behavioralReplayExact: .observedTrue,
                bitwiseReplayExact: .observedFalse
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateFixedPromptMarginObservation(
                firstGreedyTokenID: 1,
                replayGreedyTokenID: 2,
                firstRunnerUpMargin: 1,
                replayRunnerUpMargin: 1,
                maximumAbsoluteLogitDelta: 0,
                greedyTokenStable: .observedTrue,
                behavioralReplayExact: .observedTrue,
                bitwiseReplayExact: .unavailable
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateFixedPromptMarginObservation(
                firstGreedyTokenID: 1,
                replayGreedyTokenID: 1,
                firstRunnerUpMargin: 1,
                replayRunnerUpMargin: 1,
                maximumAbsoluteLogitDelta: 0.5,
                greedyTokenStable: .observedTrue,
                behavioralReplayExact: .observedTrue,
                bitwiseReplayExact: .unavailable
            )
        )
    }

    func testCapabilityStatesAreFailClosedAgainstFrozenPredicates()
        throws
    {
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCapabilitySplitObservation(
                split: .combinationHoldout,
                zeroShotExactAccuracy: 0.70,
                correctedExactAccuracy: 0.79,
                thresholdSatisfied: .observedTrue
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCapabilitySplitObservation(
                split: .abstention,
                zeroShotExactAccuracy: 0,
                correctedExactAccuracy: 1,
                thresholdSatisfied: .observedTrue
            )
        )
        let splits = try
            PrimeNativeNeuralGateSemanticCapabilitySplit
            .allCases.map {
                try PrimeNativeNeuralGateCapabilitySplitObservation(
                    split: $0,
                    zeroShotExactAccuracy: 0,
                    correctedExactAccuracy:
                        $0 == .abstention ? 1 : 0.9,
                    thresholdSatisfied: .unavailable
                )
            }
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateCapabilityObservation(
                splits: splits,
                sourceBoundRowIdentityAndCoverage: .observedTrue,
                thresholdsSatisfied: .unavailable,
                modelCapability: .unavailable
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCapabilityObservation(
                splits: splits,
                sourceBoundRowIdentityAndCoverage: .observedTrue,
                thresholdsSatisfied: .observedTrue,
                modelCapability: .observedTrue
            )
        )
    }

    func testAbstentionCapabilityRequiresExactDecisionEvidence()
        throws
    {
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCapabilitySplitObservation(
                split: .abstention,
                zeroShotExactAccuracy: 0,
                correctedExactAccuracy: 1,
                thresholdSatisfied: .observedTrue
            ),
            "perfect aggregate accuracy is not exact abstention evidence"
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCapabilitySplitObservation(
                split: .abstention,
                zeroShotExactAccuracy: 0,
                correctedExactAccuracy: 0.9,
                thresholdSatisfied: .observedFalse,
                exactAbstentionDecisionsObserved: .observedTrue
            )
        )
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateCapabilitySplitObservation(
                split: .abstention,
                zeroShotExactAccuracy: 0,
                correctedExactAccuracy: 1,
                thresholdSatisfied: .observedFalse,
                exactAbstentionDecisionsObserved: .observedFalse
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCapabilitySplitObservation(
                split: .combinationHoldout,
                zeroShotExactAccuracy: 0.7,
                correctedExactAccuracy: 0.9,
                thresholdSatisfied: .observedTrue,
                exactAbstentionDecisionsObserved: .observedTrue
            )
        )
    }

    func testTenBareTrueLegsRemainProvisionalAndAbstain()
        throws
    {
        let verdict = try makeStatisticsVerdict(
            legEvidence: .none,
            omittedPrerequisite: .sourceBoundEvidence
        )
        XCTAssertEqual(verdict.passingLegCount, 10)
        XCTAssertEqual(
            verdict.countDerivedLabel,
            "independentThreePlus(10)"
        )
        XCTAssertEqual(
            verdict.countDerivedLabelScope,
            "provisional_count_only_non_authorizing"
        )
        XCTAssertEqual(verdict.mechanicsOutcome, .abstain)
        XCTAssertFalse(verdict.mechanicsPassAuthorized)
        XCTAssertFalse(verdict.scientificAuthorityAuthorized)
        XCTAssertFalse(verdict.productAuthorityAuthorized)
        let encoded = try JSONEncoder().encode(verdict)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded)
                as? [String: Any]
        )
        XCTAssertEqual(
            object["count_derived_label_scope"] as? String,
            "provisional_count_only_non_authorizing"
        )
        let capabilityObject = try XCTUnwrap(
            object["capability"] as? [String: Any]
        )
        let splitObjects = try XCTUnwrap(
            capabilityObject["splits"]
                as? [[String: Any]]
        )
        XCTAssertEqual(
            splitObjects.last?["exact_abstention_decisions_observed"]
                as? String,
            "observed_true"
        )
    }

    func testStatisticsVerdictAbstainsForEveryMissingPrerequisite()
        throws
    {
        let prerequisites:
            [StatisticsPrerequisite] = [
                .criticalLeg,
                .weightedRecomputation,
                .greedyTokenStability,
                .behavioralReplay,
                .modelCapability,
                .mutationSweep,
                .sourceBoundEvidence,
                .distinctImplementationFamilies,
                .fourTierAudit,
            ]
        for prerequisite in prerequisites {
            let verdict = try makeStatisticsVerdict(
                omittedPrerequisite: prerequisite
            )
            XCTAssertEqual(
                verdict.mechanicsOutcome,
                .abstain,
                "missing \(prerequisite) must abstain"
            )
        }
    }

    func testStatisticsVerdictGroundsOnlyFullyBoundEvidence()
        throws
    {
        let verdict = try makeStatisticsVerdict()
        XCTAssertEqual(verdict.mechanicsOutcome, .grounded)
        XCTAssertEqual(
            verdict.fixedPromptMargin.bitwiseReplayExact,
            .unavailable,
            "behavioral replay is required; bitwise replay is not"
        )
        XCTAssertFalse(verdict.mechanicsPassAuthorized)
        XCTAssertFalse(verdict.scientificAuthorityAuthorized)
        XCTAssertFalse(verdict.productAuthorityAuthorized)

        XCTAssertThrowsError(
            try makeStatisticsVerdict(
                legEvidence: .unbound
            ),
            "a true source-bound claim cannot contain unbound leg evidence"
        )
    }

    func testHistoricalGateGroundsOnlyCompleteBoundExecution()
        throws
    {
        let grounded = try makeHistoricalGate()
        XCTAssertEqual(grounded.mechanicsOutcome, .grounded)
        XCTAssertFalse(grounded.mechanicsPassAuthorized)
        XCTAssertFalse(grounded.scientificAuthorityAuthorized)
        XCTAssertFalse(grounded.productAuthorityAuthorized)

        for index in 0 ..< 5 {
            let gate = try makeHistoricalGate(
                unboundAggregateIndex: index
            )
            XCTAssertEqual(
                gate.mechanicsOutcome,
                .abstain,
                "aggregate reference \(index) must be bound"
            )
        }
        XCTAssertEqual(
            try makeHistoricalGate(
                sourceBoundEvidence: .unavailable
            ).mechanicsOutcome,
            .abstain
        )
        XCTAssertEqual(
            try makeHistoricalGate(
                modelExecution: .unavailable
            ).mechanicsOutcome,
            .abstain
        )
        XCTAssertEqual(
            try makeHistoricalGate(
                unavailableLegOrdinal: 1
            ).mechanicsOutcome,
            .abstain
        )
        XCTAssertEqual(
            try makeHistoricalGate(
                legEvidence: .none,
                sourceBoundEvidence: .unavailable
            ).mechanicsOutcome,
            .abstain
        )
        XCTAssertThrowsError(
            try makeHistoricalGate(legEvidence: .unbound),
            "a true source-bound claim cannot contain unbound leg evidence"
        )
    }

    func testCorrectedDetectorAggregateBindsCopiedReferencesWithoutAuthority()
        throws
    {
        let stream = try
            PrimeNativeNeuralGateSemanticArtifactReference(
                schemaID:
                    "prime_stage_b_corrected_detector_record_stream_v1",
                relativePath:
                    "neural-gate-replay/corrected/mutations/corrected_fixed_cap_eos/detector-observations.v1.bin",
                contentSHA256: sha("a"),
                byteCount: 64,
                maximumByteCount: 1_048_576
            )
        let observation = try
            PrimeNativeNeuralGateCorrectedDetectorObservation(
                observationStream: stream,
                commonCaptureScheduleReferenceIdentitySHA256:
                    sha("b"),
                probeBranchReferenceIdentitySHA256: sha("c"),
                verifierBranchReferenceIdentitySHA256: sha("d"),
                exactCatalogCoverageObserved: .unavailable,
                exactFailureSetsObserved: .unavailable,
                independentDetectorObserved: .unavailable
            )
        XCTAssertNoThrow(try observation.validate())
        XCTAssertEqual(observation.exactObservationCount, 15)
        XCTAssertFalse(observation.processDeliveryObserved)
        XCTAssertFalse(observation.mechanicsPassAuthorized)
    }

    private enum LegEvidenceBinding {
        case none
        case unbound
        case bound
    }

    private enum StatisticsPrerequisite {
        case criticalLeg
        case weightedRecomputation
        case greedyTokenStability
        case behavioralReplay
        case modelCapability
        case mutationSweep
        case sourceBoundEvidence
        case distinctImplementationFamilies
        case fourTierAudit
    }

    private func makeLegs(
        passed:
            PrimeNativeNeuralGateSemanticObservationState,
        evidenceBinding: LegEvidenceBinding = .none,
        unavailableOrdinal: Int? = nil
    ) throws
        -> [PrimeNativeNeuralGateSemanticCriticalLegObservation]
    {
        try PrimeNativeNeuralGateSemanticVerdictPolicy
            .orderedCriticalLegIDs.enumerated().map {
                let ordinal = $0.offset + 1
                let evidence:
                    [PrimeNativeNeuralGateSemanticArtifactReference]
                switch evidenceBinding {
                case .none:
                    evidence = []
                case .unbound,
                     .bound:
                    evidence = [
                        try makeArtifactReference(
                            relativePath:
                                "semantic-test/critical-leg-\(ordinal).json",
                            bound: evidenceBinding == .bound
                        ),
                    ]
                }
                return try PrimeNativeNeuralGateSemanticCriticalLegObservation(
                    ordinal: ordinal,
                    legID: $0.element,
                    passed: unavailableOrdinal == ordinal
                        ? .unavailable
                        : passed,
                    detail: "schema test",
                    evidence: evidence
                )
            }
    }

    private func makeStatisticsVerdict(
        legEvidence: LegEvidenceBinding = .bound,
        omittedPrerequisite: StatisticsPrerequisite? = nil
    ) throws -> PrimeNativeNeuralGateStatisticsVerdictObservation {
        let weighted = try
            PrimeNativeNeuralGateWeightedStatisticsObservation(
                rowCount: 1,
                totalTargetTokenCount: 1,
                weightedMeanBefore: 1,
                weightedMeanAfter: 0.5,
                effectiveRows: 1,
                unbiasedVarianceDenominator: 0,
                weightedVarianceAfter: 0,
                standardErrorAfter: 0,
                recomputationObserved:
                    omittedPrerequisite == .weightedRecomputation
                        ? .unavailable
                        : .observedTrue
            )
        let margin = try
            PrimeNativeNeuralGateFixedPromptMarginObservation(
                firstGreedyTokenID: 1,
                replayGreedyTokenID: 1,
                firstRunnerUpMargin: 1,
                replayRunnerUpMargin: 1,
                maximumAbsoluteLogitDelta: 0,
                greedyTokenStable:
                    omittedPrerequisite == .greedyTokenStability
                        ? .unavailable
                        : .observedTrue,
                behavioralReplayExact:
                    omittedPrerequisite == .behavioralReplay
                        ? .unavailable
                        : .observedTrue,
                bitwiseReplayExact: .unavailable
            )
        let capability = try makeCapability(
            modelCapability:
                omittedPrerequisite == .modelCapability
                    ? .unavailable
                    : .observedTrue
        )
        let legs = try makeLegs(
            passed: .observedTrue,
            evidenceBinding: legEvidence,
            unavailableOrdinal:
                omittedPrerequisite == .criticalLeg ? 1 : nil
        )
        return try PrimeNativeNeuralGateStatisticsVerdictObservation(
            arm: .correctedFixedCapEOS,
            weightedStatistics: weighted,
            fixedPromptMargin: margin,
            capability: capability,
            criticalLegs: legs,
            mutationSweepSatisfied:
                omittedPrerequisite == .mutationSweep
                    ? .unavailable
                    : .observedTrue,
            sourceBoundCriticalLegEvidence:
                omittedPrerequisite == .sourceBoundEvidence
                    ? .unavailable
                    : .observedTrue,
            distinctImplementationFamiliesEstablished:
                omittedPrerequisite
                    == .distinctImplementationFamilies
                    ? .unavailable
                    : .observedTrue,
            agentContractKitFourTierAuditPerformed:
                omittedPrerequisite == .fourTierAudit
                    ? .unavailable
                    : .observedTrue
        )
    }

    private func makeCapability(
        modelCapability:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws -> PrimeNativeNeuralGateCapabilityObservation {
        let splits = try
            PrimeNativeNeuralGateSemanticCapabilitySplit
            .allCases.map { split in
                try PrimeNativeNeuralGateCapabilitySplitObservation(
                    split: split,
                    zeroShotExactAccuracy: 0,
                    correctedExactAccuracy:
                        split == .abstention ? 1 : 0.9,
                    thresholdSatisfied: .observedTrue,
                    exactAbstentionDecisionsObserved:
                        split == .abstention
                            ? .observedTrue
                            : .unavailable
                )
            }
        return try PrimeNativeNeuralGateCapabilityObservation(
            splits: splits,
            sourceBoundRowIdentityAndCoverage: .observedTrue,
            thresholdsSatisfied: .observedTrue,
            modelCapability: modelCapability
        )
    }

    private func makeHistoricalGate(
        unboundAggregateIndex: Int? = nil,
        legEvidence: LegEvidenceBinding = .bound,
        unavailableLegOrdinal: Int? = nil,
        sourceBoundEvidence:
            PrimeNativeNeuralGateSemanticObservationState = .observedTrue,
        modelExecution:
            PrimeNativeNeuralGateSemanticObservationState = .observedTrue
    ) throws -> PrimeNativeNeuralGateHistoricalGateObservation {
        let prefix = "neural-gate-replay/historical/probe"
        let paths = [
            "material-identity-manifest.v1.json",
            "invariant-records-manifest.v1.json",
            "fingerprint-observation.v1.json",
            "mutation-observations.v1.json",
            "statistics-verdict-observation.v1.json",
        ]
        let references = try paths.enumerated().map {
            try makeArtifactReference(
                relativePath: "\(prefix)/\($0.element)",
                bound: $0.offset != unboundAggregateIndex
            )
        }
        return try PrimeNativeNeuralGateHistoricalGateObservation(
            invocationRole: .probe,
            materialIdentity: references[0],
            invariantManifest: references[1],
            fingerprintObservation: references[2],
            mutationObservation: references[3],
            statisticsVerdictObservation: references[4],
            criticalLegs: try makeLegs(
                passed: .observedTrue,
                evidenceBinding: legEvidence,
                unavailableOrdinal: unavailableLegOrdinal
            ),
            sourceBoundCriticalLegEvidence:
                sourceBoundEvidence,
            modelExecutionObserved: modelExecution
        )
    }

    private func makeArtifactReference(
        relativePath: String,
        bound: Bool
    ) throws -> PrimeNativeNeuralGateSemanticArtifactReference {
        try PrimeNativeNeuralGateSemanticArtifactReference(
            schemaID: "prime_semantic_test_artifact_v1",
            relativePath: relativePath,
            contentSHA256: sha("a"),
            byteCount: 1,
            maximumByteCount: 1,
            descriptorContentVerified:
                bound ? .observedTrue : .unavailable,
            durablePublicationObserved:
                bound ? .observedTrue : .unavailable
        )
    }

    private func sha(_ character: Character) -> String {
        String(repeating: String(character), count: 64)
    }
}
