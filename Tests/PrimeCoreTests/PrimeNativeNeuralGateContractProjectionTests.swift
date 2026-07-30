import Foundation
import Testing
@testable import PrimeCore
@testable import PrimeNativeNeuralGateContract

@Suite
struct PrimeNativeNeuralGateContractProjectionTests {
    @Test
    func historicalParentsBindExactReceiptAndSourcePairs()
        throws
    {
        let plan =
            PrimeNativeNeuralGateContractPlan
            .frozenV1
        try plan.validate()

        #expect(
            plan.generationReceiptSHA256
                == "05d135bb04bc377b85b7bce98a6eebbab35a80172567407d2c4625f4af9b990b"
        )
        #expect(
            plan
                .generationParentSourceIdentitySHA256
                == "a634994a9aedb2803b61353ffd30f0fcd0f1bad4356ce738f7d150f3cd08d2fb"
        )
        #expect(
            plan.corpusReplayReceiptSHA256
                == "88d243827c1aff0ce8125402f84c4ffe4012d058dedaf88f614099e975dafdc2"
        )
        #expect(
            plan
                .corpusReplayParentSourceIdentitySHA256
                == "d13a817e2918e94972174b78eb1372dd0d4395161fca08b63850e7c2bfbbb08f"
        )
        #expect(
            plan
                .generationParentSourceIdentitySHA256
                != plan
                .corpusReplayParentSourceIdentitySHA256
        )
    }

    @Test
    func frozenProjectionBindsExactDonorAuthority()
        throws
    {
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        try projection.validate()

        #expect(
            projection.sourceBindings.map(\.role)
                == PrimeNativeNeuralGateSourceRole
                .allCases
        )
        #expect(
            projection.sourceBindings.map(\.sha256)
                == [
                    "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6",
                    "9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721",
                    "4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210",
                    "8706343bf93c1dac70f5c263f7111667574da751cd27d6c3321a92fd822f063f",
                    "1f770ed0a044597f6efd7ce1d74e14763cc5e64eeaa0e4036001a311d9e41c7b",
                    "cfeb5d3e3d3a39001f569239f5f9f4c1cb1c669342b366b12930793d36826f7c",
                    "42d022ad2f9c423c9d1ff9e7fc52fc6576a51320a972c738d9d98fd84a956463",
                    "7cdc5ec341d7527c873b458c2ccb24ca27f9104709e9c37066d755bbb951a7ea",
                    "7f5ee1ee5579d13cec0ea4802994e6f07c4117c8202714f40fe1e3a0de21a42c",
                    "266475d337fb49ba9c84e03a53871269a73812c3200a830a799ef90f4901968c",
                ]
        )
        #expect(projection.criticalLegs.count == 10)
        #expect(
            projection.criticalLegs.first?.legID
                == "NL1_canonical_material_reload"
        )
        #expect(
            projection.criticalLegs.last?.legID
                == "NL10_mutation_synthesis"
        )
        #expect(
            projection.mutationCatalog.count == 46
        )
        #expect(
            projection.mutationCatalog.map(
                \.mutationID
            )
                == PrimeNativeNeuralGateMutation
                .allCases.map(\.rawValue)
        )
    }

    @Test
    func mutationCatalogPreservesExpectedLegAndRawBoundary()
    {
        let catalog =
            PrimeNativeNeuralGateContractProjection
            .frozenV1.mutationCatalog

        #expect(
            catalog.first {
                $0.mutationID
                    == "target_length_oracle_leakage"
            }?.expectedFailedLeg
                == "NL4_raw_executor_row_regrade"
        )
        #expect(
            catalog.first {
                $0.mutationID
                    == "cached_uncached_multi_step_parity"
            }?.expectedFailedLeg
                == "NL5_causal_training_mechanics"
        )
        #expect(
            catalog.first {
                $0.mutationID
                    == "trained_support_assistance"
            }?.expectedFailedLeg
                == "NL9_capability_and_malformed_abstention"
        )
        #expect(
            catalog.filter(
                \.mutatesRawPredictions
            ).count == 12
        )
    }

    @Test
    func finiteFieldProjectionMatchesFrozenRawUTF8Vector()
        throws
    {
        let field =
            PrimeNativeNeuralGateFiniteFieldContract
            .frozenV1
        let records =
            PrimeNativeNeuralGateContractObservation
            .contractVectorRecordsV1
        let fingerprint =
            try field.fingerprint(records: records)

        #expect(
            fingerprint.prime == 2_147_483_647
        )
        #expect(
            fingerprint.evaluationPoints
                == [257, 65_537, 1_000_003]
        )
        #expect(
            fingerprint.residues
                == [
                    1_929_142_910,
                    1_440_393_600,
                    837_181_579,
                ]
        )
        #expect(fingerprint.recordCount == 5)
        #expect(
            try field.fingerprint(
                records: Array(records.reversed())
            ) == fingerprint
        )

        let ascii = try field.fingerprint(
            records: ["canonical|K"]
        )
        let canonicalEquivalentUnicode =
            try field.fingerprint(
                records: ["canonical|\u{212A}"]
            )
        #expect("canonical|K" == "canonical|\u{212A}")
        #expect(
            ascii != canonicalEquivalentUnicode
        )
    }

    @Test
    func statisticalAndVerdictLimitsStayExplicit()
        throws
    {
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        try projection.statistics.validate()
        try projection.capabilityThresholds.validate()
        try projection.verdict.validate()

        #expect(
            projection.capabilityThresholds
                .requiredTotalRows
                == 18_432
        )
        #expect(
            projection.statistics.lossAggregationID
                == "target_token_weighted_row_unbiased_effective_n_v1"
        )
        #expect(
            projection.statistics
                .effectiveSampleSizeFormula
                == "square_sum_w_div_max_1_sum_square_w"
        )
        #expect(
            projection.statistics
                .unbiasedWeightedVarianceDenominator
                == "sum_w_minus_sum_square_w_div_max_1_sum_w"
        )
        #expect(
            projection.statistics
                .nonpositiveVarianceDenominatorBehavior
                == "variance_zero"
        )
        #expect(
            projection.statistics
                .weightedSquaredDeviationFormula
                == "sum_w_times_square_x_after_minus_weighted_mean_after"
        )
        #expect(
            projection.statistics
                .weightedVarianceFormula
                == "weighted_squared_deviation_div_unbiased_denominator_when_positive"
        )
        #expect(
            projection.statistics
                .fixedPromptRunnerUpMarginReplayRequired
        )
        #expect(
            projection.statistics
                .fixedPromptReplayEvidenceFieldsMustEqualRecomputation
        )
        #expect(
            projection.statistics
                .fixedPromptResultExactIsBitwiseLogitEquality
        )
        #expect(
            !projection.statistics
                .perFamilyRankMarginStatisticalAnalysisIncluded
        )
        #expect(
            !projection.statistics
                .perFamilyDecisionMarginStatisticalAnalysisIncluded
        )
        #expect(
            !projection.statistics
                .confidenceIntervalsIncluded
        )
        #expect(
            !projection.statistics
                .guardedStatisticalEntanglementIncluded
        )
        #expect(
            projection.verdict
                .allCriticalLegsRequiredForGrounded
        )
        #expect(
            projection.verdict
                .minimumIndependentPassingCountForCountLabel
                == 3
        )
        #expect(
            projection.verdict.triadicSemantics
                == "count_derived_label_not_four_tier_independence_audit"
        )
        #expect(
            !projection.verdict
                .agentContractKitFourTierAuditPerformed
        )
    }

    @Test
    func projectionCanonicalRoundTripIsExact()
        throws
    {
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        let data =
            try PrimeCanonicalJSON.encode(
                projection
            )
        let decoded =
            try PrimeCanonicalJSON.decode(
                PrimeNativeNeuralGateContractProjection
                    .self,
                from: data
            )
        #expect(decoded == projection)
        try decoded.validate()
        #expect(
            try decoded.contentSHA256()
                == PrimeSHA256.hexDigest(of: data)
        )
    }

    @Test
    func structuralProjectionSweepIsCompleteAndDistinct()
        throws
    {
        let records =
            try PrimeNativeNeuralGateContractOverlay
            .projectionMutationSweep()
        #expect(
            records.map(\.mutation)
                == PrimeNativeNeuralGateProjectionMutation
                .allCases
        )
        #expect(
            records.allSatisfy {
                $0.detected
                    && $0.restored
                    && !$0
                    .historicalSemanticMutationExecuted
                    && !$0
                    .independentScientificOracleClaimed
            }
        )
    }

    @Test
    func observationDisclosesUnexecutedHistoricalWork()
        throws
    {
        let observation =
            try PrimeNativeNeuralGateContractObservation
            .runAndValidate()
        #expect(observation.sourcePinCount == 10)
        #expect(observation.criticalLegCount == 10)
        #expect(
            observation.historicalMutationContractCount
                == 46
        )
        #expect(
            observation.projectionMutationSweep.count
                == 12
        )
        #expect(
            observation
                .finiteFieldContractVectorComputed
        )
        #expect(
            !observation
                .historicalInvariantRecordsObserved
        )
        #expect(
            !observation
                .historicalSemanticMutationsExecuted
        )
        #expect(
            !observation
                .historicalSZFingerprintRecomputed
        )
    }

    @Test
    func processIdentityGateRejectsMissingAndSameProcess()
        throws
    {
        try PrimeNativeNeuralGateContractOverlay
            .requireDistinctProcessIdentifiers(
                probe: 10,
                verifier: 11
            )
        #expect(throws: Error.self) {
            try PrimeNativeNeuralGateContractOverlay
                .requireDistinctProcessIdentifiers(
                    probe: 10,
                    verifier: 10
                )
        }
        #expect(throws: Error.self) {
            try PrimeNativeNeuralGateContractOverlay
                .requireDistinctProcessIdentifiers(
                    probe: 0,
                    verifier: 11
                )
        }
    }
}
