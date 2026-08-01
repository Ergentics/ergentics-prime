import XCTest
import PrimeNativeNeuralGateCorrectedMutationProducer
import PrimeNativeNeuralGateCorrectedMutationSurfaceContracts
import PrimeNativeNeuralGateSemanticRecordContracts

final class PrimeNativeNeuralGateCorrectedMutationProducerTests:
    XCTestCase
{
    func testBatchProducerEmitsExactCatalogFromOneCommonContext()
        throws
    {
        let batch =
            try PrimeNativeNeuralGateCorrectedMutationProducer
            .produceBatch(baseline: makeBaseline())
        let contract =
            PrimeNativeNeuralGateCorrectedMutationRecordContract
            .frozenV1
        XCTAssertEqual(
            batch.count,
            PrimeNativeNeuralGateCorrectedMutationSurfaceContract
                .exactBlindBatchCount
        )
        XCTAssertEqual(
            batch.map(\.identity.mutationID),
            contract.orderedMutationCatalog.map(\.mutationID)
        )
        let common = try XCTUnwrap(batch.first)
        XCTAssertTrue(
            batch.allSatisfy {
                $0.baseline == common.baseline
                    && $0.restored == common.baseline
            }
        )
        XCTAssertEqual(
            Set(batch.map(\.mutated.binding.surfaceSHA256))
                .count,
            batch.count
        )
        XCTAssertEqual(
            batch.map(\.blindTriplet),
            batch.map {
                PrimeNativeNeuralGateBlindCorrectedMutationTriplet(
                    baseline: $0.baseline,
                    mutated: $0.mutated,
                    restored: $0.restored
                )
            }
        )
    }

    func testFrozenCatalogAndEveryProducerTransformAreExact()
        throws
    {
        let contract =
            PrimeNativeNeuralGateCorrectedMutationRecordContract
            .frozenV1
        try contract.validate()
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_corrected_mutation_control_surface_contract_v1"
        )
        XCTAssertEqual(
            contract.surfaceContractID,
            "prime_stage_b_corrected_mutation_label_free_surface_contract_v1"
        )
        XCTAssertEqual(
            contract.surfaceSerializationContractID,
            "pmutrec1_fixed_order_lowercase_ascii_hex_presence_only_control_surface_v1"
        )
        XCTAssertNotEqual(
            contract.contractID,
            contract.surfaceContractID
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "9b40258ed7ba07dc62ff6bda96df03b2233575a039b5598b487d738d036a78bd"
        )
        XCTAssertEqual(
            contract.orderedMutationCatalog.map(
                \.mutationID
            ),
            PrimeNativeNeuralGateCorrectedMutationCaseID
                .allCases
        )
        XCTAssertEqual(
            contract.orderedMutationCatalog.map(
                \.ordinal
            ),
            (1 ... 15).map(UInt32.init)
        )
        XCTAssertTrue(
            contract.orderedMutationCatalog.allSatisfy {
                $0.arm == .correctedFixedCapEOS
                    && $0.exactAllowedFailedLegIDSets
                        == [
                            [
                                $0.mutationID
                                    .expectedFailedLegID,
                            ],
                        ]
            }
        )

        let baseline = try makeBaseline()
        let expectedChangedControl: [
            PrimeNativeNeuralGateCorrectedMutationCaseID:
                String
        ] = [
            .targetValueChangesRawExecution:
                "target_value_raw_identity",
            .targetLengthChangesRawExecution:
                "target_length_raw_identity",
            .expectedCompletionInjectedIntoPrediction:
                "prediction_expected_completion",
            .targetDependentPromptGrouping:
                "prompt_grouping",
            .targetDependentDecisionBudget:
                "decision_budget",
            .eosUnavailableAtDecision:
                "eos_availability",
            .completionSupportNarrowed:
                "completion_support",
            .fixedCapDrift: "fixed_cap",
            .targetDependentTermination:
                "termination",
            .targetDependentRowInclusion:
                "row_inclusion",
            .correlationRowIDInjectedIntoPrediction:
                "prediction_row_id",
            .correlationSplitInjectedIntoPrediction:
                "prediction_split",
            .correlationSemanticFamilyInjectedIntoPrediction:
                "prediction_semantic_family",
            .rowDependentEvaluationSeed:
                "replicate_seed_scope",
            .retainedStateChangesPermutedRowTrace:
                "row_state",
        ]

        for entry in contract.orderedMutationCatalog {
            let produced =
                try PrimeNativeNeuralGateCorrectedMutationProducer
                .produce(
                    mutationID: entry.mutationID,
                    baseline: baseline
                )
            XCTAssertEqual(
                produced.identity.ordinal,
                entry.ordinal
            )
            XCTAssertEqual(
                produced.identity.mutationID,
                entry.mutationID
            )
            XCTAssertEqual(
                produced.identity
                    .exactAllowedFailedLegIDSets,
                entry.exactAllowedFailedLegIDSets
            )
            let baselineMaterial =
                try PrimeNativeNeuralGateCorrectedControlSurfaceBinder
                .validateAndDecode(produced.baseline)
            let mutatedMaterial =
                try PrimeNativeNeuralGateCorrectedControlSurfaceBinder
                .validateAndDecode(produced.mutated)
            let restoredMaterial =
                try PrimeNativeNeuralGateCorrectedControlSurfaceBinder
                .validateAndDecode(produced.restored)
            XCTAssertEqual(baselineMaterial, baseline)
            XCTAssertEqual(restoredMaterial, baseline)
            XCTAssertNotEqual(mutatedMaterial, baseline)
            XCTAssertEqual(
                changedControls(
                    from: baselineMaterial,
                    to: mutatedMaterial
                ),
                [try XCTUnwrap(
                    expectedChangedControl[
                        entry.mutationID
                    ]
                )]
            )
            XCTAssertEqual(
                produced.baseline,
                produced.restored
            )
            XCTAssertNotEqual(
                produced.baseline.bytes,
                produced.mutated.bytes
            )
            XCTAssertNotEqual(
                produced.baseline.binding.surfaceSHA256,
                produced.mutated.binding.surfaceSHA256
            )
            XCTAssertNotEqual(
                produced.baseline.binding
                    .invariantGlobalStreamSHA256,
                produced.mutated.binding
                    .invariantGlobalStreamSHA256
            )
            XCTAssertNotEqual(
                produced.baseline.binding.directFingerprint,
                produced.mutated.binding.directFingerprint
            )
            XCTAssertNotEqual(
                produced.baseline.binding
                    .acceleratedFingerprint,
                produced.mutated.binding
                    .acceleratedFingerprint
            )
            for surface in [
                produced.baseline,
                produced.mutated,
                produced.restored,
            ] {
                XCTAssertEqual(
                    surface.binding.directFingerprint,
                    surface.binding
                        .acceleratedFingerprint
                )
                XCTAssertEqual(
                    surface.binding.surfaceByteCount,
                    surface.bytes.count
                )
                XCTAssertEqual(
                    surface.bytes.count,
                    PrimeNativeNeuralGateCorrectedControlSurfaceCodec
                        .encodedByteCount
                )
                let text = String(
                    decoding: surface.bytes,
                    as: UTF8.self
                )
                for mutationID in
                    PrimeNativeNeuralGateCorrectedMutationCaseID
                    .allCases
                {
                    XCTAssertFalse(
                        text.contains(mutationID.rawValue)
                    )
                }
                for legID in
                    PrimeNativeNeuralGateCorrectedControlLegID
                    .allCases
                {
                    XCTAssertFalse(
                        text.contains(legID.rawValue)
                    )
                }
            }
        }
    }

    func testProducerUsesDistinctPredictionInjectionChannels()
        throws
    {
        let baseline = try makeBaseline()
        let expected =
            try PrimeNativeNeuralGateCorrectedMutationProducer
            .produce(
                mutationID:
                    .expectedCompletionInjectedIntoPrediction,
                baseline: baseline
            )
        let row =
            try PrimeNativeNeuralGateCorrectedMutationProducer
            .produce(
                mutationID:
                    .correlationRowIDInjectedIntoPrediction,
                baseline: baseline
            )
        let split =
            try PrimeNativeNeuralGateCorrectedMutationProducer
            .produce(
                mutationID:
                    .correlationSplitInjectedIntoPrediction,
                baseline: baseline
            )
        let family =
            try PrimeNativeNeuralGateCorrectedMutationProducer
            .produce(
                mutationID:
                    .correlationSemanticFamilyInjectedIntoPrediction,
                baseline: baseline
            )
        let values = try [expected, row, split, family].map {
            try PrimeNativeNeuralGateCorrectedControlSurfaceBinder
                .validateAndDecode($0.mutated)
        }
        XCTAssertEqual(
            values.map(\.predictionExpectedCompletionPresent),
            [true, false, false, false]
        )
        XCTAssertEqual(
            values.map(\.predictionRowIDPresent),
            [false, true, false, false]
        )
        XCTAssertEqual(
            values.map(\.predictionSplitPresent),
            [false, false, true, false]
        )
        XCTAssertEqual(
            values.map(\.predictionSemanticFamilyPresent),
            [false, false, false, true]
        )
        for produced in [expected, row, split, family] {
            let text = String(
                decoding: produced.mutated.bytes,
                as: UTF8.self
            )
            XCTAssertFalse(
                text.contains("EXPECTED_COMPLETION_INJECTED")
            )
            XCTAssertFalse(text.contains("row:injected"))
            XCTAssertFalse(text.contains("holdout"))
            XCTAssertFalse(
                text.contains("conservation_reversal")
            )
        }
    }

    func testProducerRejectsNonbaselineInput() throws {
        let baseline = try makeBaseline()
        let invalid =
            try PrimeNativeNeuralGateCorrectedControlMaterial(
                commonCaptureScheduleReferenceSHA256:
                    baseline
                    .commonCaptureScheduleReferenceSHA256,
                branchCaptureScheduleReferenceSHA256:
                    baseline
                    .branchCaptureScheduleReferenceSHA256,
                targetValueAffectsRawIdentity: false,
                targetLengthAffectsRawIdentity: false,
                predictionExpectedCompletionPresent: false,
                predictionRowIDPresent: false,
                predictionSplitPresent: false,
                predictionSemanticFamilyPresent: false,
                promptGrouping: .targetDependent,
                decisionBudget: .fixedPolicy,
                eosAvailableAtEveryDecision: true,
                completionSupport:
                    .eosAndFullByteVocabulary,
                fixedDecisionCap: 64,
                termination: .eosOrFixedCap,
                rowInclusion: .allSourceRows,
                replicateSeed: 1_618,
                replicateSeedScope: .replicate,
                rowState: .freshPerRow
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCorrectedMutationProducer
                .produce(
                    mutationID:
                        .targetValueChangesRawExecution,
                    baseline: invalid
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateCorrectedMutationProducerError,
                .invalidBaseline
            )
        }
    }

    private func makeBaseline() throws
        -> PrimeNativeNeuralGateCorrectedControlMaterial
    {
        try PrimeNativeNeuralGateCorrectedControlMaterial
            .baseline(
                commonCaptureScheduleReferenceSHA256:
                    String(repeating: "a", count: 64),
                branchCaptureScheduleReferenceSHA256:
                    String(repeating: "b", count: 64),
                replicateSeed: 1_618
            )
    }

    private func changedControls(
        from lhs:
            PrimeNativeNeuralGateCorrectedControlMaterial,
        to rhs:
            PrimeNativeNeuralGateCorrectedControlMaterial
    ) -> [String] {
        [
            (
                "common_reference",
                lhs.commonCaptureScheduleReferenceSHA256
                    != rhs.commonCaptureScheduleReferenceSHA256
            ),
            (
                "branch_reference",
                lhs.branchCaptureScheduleReferenceSHA256
                    != rhs.branchCaptureScheduleReferenceSHA256
            ),
            (
                "target_value_raw_identity",
                lhs.targetValueAffectsRawIdentity
                    != rhs.targetValueAffectsRawIdentity
            ),
            (
                "target_length_raw_identity",
                lhs.targetLengthAffectsRawIdentity
                    != rhs.targetLengthAffectsRawIdentity
            ),
            (
                "prediction_expected_completion",
                lhs.predictionExpectedCompletionPresent
                    != rhs.predictionExpectedCompletionPresent
            ),
            (
                "prediction_row_id",
                lhs.predictionRowIDPresent
                    != rhs.predictionRowIDPresent
            ),
            (
                "prediction_split",
                lhs.predictionSplitPresent
                    != rhs.predictionSplitPresent
            ),
            (
                "prediction_semantic_family",
                lhs.predictionSemanticFamilyPresent
                    != rhs.predictionSemanticFamilyPresent
            ),
            (
                "prompt_grouping",
                lhs.promptGrouping != rhs.promptGrouping
            ),
            (
                "decision_budget",
                lhs.decisionBudget != rhs.decisionBudget
            ),
            (
                "eos_availability",
                lhs.eosAvailableAtEveryDecision
                    != rhs.eosAvailableAtEveryDecision
            ),
            (
                "completion_support",
                lhs.completionSupport
                    != rhs.completionSupport
            ),
            (
                "fixed_cap",
                lhs.fixedDecisionCap != rhs.fixedDecisionCap
            ),
            (
                "termination",
                lhs.termination != rhs.termination
            ),
            (
                "row_inclusion",
                lhs.rowInclusion != rhs.rowInclusion
            ),
            (
                "replicate_seed",
                lhs.replicateSeed != rhs.replicateSeed
            ),
            (
                "replicate_seed_scope",
                lhs.replicateSeedScope
                    != rhs.replicateSeedScope
            ),
            (
                "row_state",
                lhs.rowState != rhs.rowState
            ),
        ].filter(\.1).map(\.0)
    }
}
