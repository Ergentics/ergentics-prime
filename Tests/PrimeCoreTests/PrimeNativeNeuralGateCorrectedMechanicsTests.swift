import Foundation
import PrimeCore
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateCorrectedEvaluationMechanics
import PrimeNativeNeuralGateReplayMechanics
import XCTest

final class PrimeNativeNeuralGateCorrectedMechanicsTests:
    XCTestCase
{
    private typealias Policy =
        PrimeNativeNeuralGateCorrectedExecutionPolicy
    private typealias Input =
        PrimeNativeNeuralGatePromptOnlyExecutionInput
    private typealias Decision =
        PrimeNativeNeuralGateCompletionDecision
    private typealias Execution =
        PrimeNativeNeuralGateRawExecution

    private func logits(
        selecting tokenID: Int,
        selectedScore: Float = 8,
        otherScore: Float = -8
    ) -> [Float] {
        var result = Array(
            repeating: otherScore,
            count: Policy.fullVocabularyLogitCount
        )
        XCTAssertTrue(
            (0 ..< Policy.fullVocabularyLogitCount)
                .contains(tokenID)
        )
        result[tokenID] = selectedScore
        return result
    }

    private func decisions(
        selecting tokenIDs: [Int]
    ) throws -> [Decision] {
        try tokenIDs.enumerated().map {
            try Decision.make(
                ordinal: $0.offset + 1,
                fullVocabularyLogits:
                    logits(selecting: $0.element)
            )
        }
    }

    private func execution(
        selecting tokenIDs: [Int],
        prompt: String = "Solve this.",
        seed: Int = 1_618
    ) throws -> Execution {
        let input = try Input.derive(
            promptText: prompt
        )
        let context =
            try PrimeNativeNeuralGateCorrectedReplicateContext(
                evaluationSeed: seed
            )
        return try Execution.validate(
            replicateContext: context,
            input: input,
            decisions:
                decisions(selecting: tokenIDs)
        )
    }

    private func correctedTargetClosureSwiftFiles()
        throws -> [URL]
    {
        let roots = [
            "PrimeNativeNeuralGateCorrectedMechanics",
            "PrimeNativeNeuralGateReplayMechanics",
        ].map {
            URL(
                fileURLWithPath: "Sources/\($0)",
                isDirectory: true
            )
        }
        var files: [URL] = []
        for root in roots {
            guard let enumerator =
                FileManager.default.enumerator(
                    at: root,
                    includingPropertiesForKeys: [
                        .isRegularFileKey,
                    ],
                    options: [
                        .skipsHiddenFiles,
                    ]
                )
            else {
                throw CocoaError(
                    .fileReadUnknown
                )
            }
            for case let file as URL in enumerator
                where file.pathExtension == "swift"
            {
                let values = try file.resourceValues(
                    forKeys: [
                        .isRegularFileKey,
                    ]
                )
                if values.isRegularFile == true {
                    files.append(file)
                }
            }
        }
        return files.sorted {
            $0.path < $1.path
        }
    }

    func testPredictionInputStoredShapeExcludesCorrelationAndEvaluationAuthority()
        throws
    {
        let input = try Input.derive(
            promptText: "Café?"
        )
        XCTAssertEqual(
            Mirror(reflecting: input)
                .children
                .compactMap(\.label),
            [
                "promptTokenIDs",
            ]
        )
        XCTAssertFalse(
            Input.self is any Codable.Type
        )
        XCTAssertEqual(
            try input.decodedCanonicalPrompt(),
            "Café?"
        )
        XCTAssertEqual(
            input.promptTokenIDs.first,
            Policy.beginningOfSequenceTokenID
        )
        XCTAssertEqual(
            input.promptTokenIDs.count,
            Array("Café?".utf8).count + 1
        )
        XCTAssertEqual(
            Policy.orderedCompletionSupport.count,
            257
        )
        XCTAssertEqual(
            Set(Policy.orderedCompletionSupport)
                .count,
            257
        )
        XCTAssertEqual(
            Policy.orderedCompletionSupport.first,
            Policy.endOfSequenceTokenID
        )
        XCTAssertEqual(
            Policy.orderedCompletionSupportSHA256,
            Policy
                .orderedCompletionSupportKnownAnswerSHA256
        )
    }

    func testCorrectedPolicyConformsToFrozenGenerationAndAdmissionContracts()
        throws
    {
        let generation =
            PrimeNativeGenerationContractProjection
            .frozenV1
        let plan =
            PrimeNativeNeuralGateFixtureReplayPlan
            .frozenV3
        let admission =
            plan.correctedExecutionAdmission

        XCTAssertEqual(
            Policy.admittedEvaluationSeeds,
            [
                1_618,
                2_718,
                3_141,
            ]
        )
        XCTAssertEqual(
            Policy.admittedEvaluationSeeds,
            admission.admittedEvaluationSeeds
        )
        XCTAssertEqual(
            Policy.beginningOfSequenceTokenID,
            generation.beginningOfSequenceTokenID
        )
        XCTAssertEqual(
            Policy.endOfSequenceTokenID,
            generation.endOfSequenceTokenID
        )
        XCTAssertEqual(
            Policy.byteTokenRange,
            generation.byteTokenLowerBound
                ... generation.byteTokenUpperBound
        )
        XCTAssertEqual(
            Policy.fullVocabularyLogitCount,
            generation.tokenizerVocabularySize
        )
        XCTAssertEqual(
            Policy.maximumGenerationDecisions,
            generation
                .maximumGenerationTokenDecisions
        )
        XCTAssertEqual(
            Policy.orderedCompletionSupport,
            generation.allowedCompletionTokenIDs
        )
        XCTAssertEqual(
            generation
                .allowedCompletionTokenSetSerialization,
            "decimal_token_ids_joined_by_lf_without_trailing_lf_v1"
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of:
                    Data(
                        Policy
                            .orderedCompletionSupport
                            .map(String.init)
                            .joined(separator: "\n")
                            .utf8
                    )
            ),
            generation
                .allowedCompletionTokenSetSHA256
        )
        XCTAssertTrue(
            generation
                .fullVocabularySupportAuditRequired
        )
        XCTAssertEqual(
            generation
                .selectedTokenLogProbabilityPolicy,
            "selected_allowed_token_log_probability_from_full_512_token_logsoftmax_v1"
        )
        XCTAssertFalse(
            generation
                .allowedSupportRenormalizationApplied
        )
        XCTAssertEqual(
            Policy.probabilityDiagnosticPolicyID,
            "foundation_double_stable_logsumexp_over_float32_full_vocabulary_logits_non_evidentiary_v1"
        )
        XCTAssertNotEqual(
            Policy.probabilityDiagnosticPolicyID,
            generation
                .fullVocabularyWitness
                .logSoftmaxPolicy
        )
        XCTAssertEqual(
            admission.pureCorrectedMechanicsTarget,
            "PrimeNativeNeuralGateCorrectedMechanics"
        )
        XCTAssertEqual(
            admission.pureCorrectedMechanicsDependencies,
            [
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )
        XCTAssertTrue(
            admission
                .sourceBoundFixtureIdentityAndExactRowCountBound
        )
        XCTAssertFalse(
            admission
                .pureCompletionFeasibilityObservationAuthoritative
        )
        XCTAssertFalse(
            admission.promptOnlySolverSourceDerivationBound
        )
        XCTAssertFalse(
            admission.solverMayReceiveCorpusRow
        )
        XCTAssertFalse(
            admission
                .solverMayReceiveTargetOrRegradeMaterial
        )
        XCTAssertFalse(
            admission.trapBearingDonorDependencyPermitted
        )
        XCTAssertTrue(
            admission.fullVocabularyLogitsRequired
        )
        XCTAssertFalse(
            admission
                .boundedFullVocabularyLogitArtifactBound
        )
        XCTAssertTrue(
            admission
                .sourcePinnedFloat32LogSoftmaxRecomputationRequired
        )
        XCTAssertFalse(
            admission
                .sourcePinnedFloat32LogSoftmaxRecomputationBound
        )
        XCTAssertFalse(
            admission
                .foundationDoubleProbabilityDiagnosticAuthoritative
        )
        XCTAssertFalse(
            admission.correctedFixtureExecutionAuthorized
        )
        XCTAssertFalse(
            admission.terminalReceiptAuthorized
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateCorrectedMutationID
                .allCases.map(\.rawValue),
            plan.correctedMutationCatalog.map {
                $0.mutation.rawValue
            }
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateCorrectedMutationID
                .allCases.map(\.expectedFailedLeg),
            plan.correctedMutationCatalog.map(
                \.expectedFailedLeg
            )
        )
    }

    func testCanonicalPromptAndSeedReplayAreExact()
        throws
    {
        let composed = try Input.derive(
            promptText: "\u{00e9}"
        )
        let decomposed = try Input.derive(
            promptText: "e\u{0301}"
        )
        XCTAssertEqual(composed, decomposed)
        XCTAssertEqual(
            composed.canonicalBindingData(),
            decomposed.canonicalBindingData()
        )
        XCTAssertEqual(
            composed.bindingSHA256,
            decomposed.bindingSHA256
        )

        for seed in
            Policy.admittedEvaluationSeeds
        {
            let firstContext =
                try PrimeNativeNeuralGateCorrectedReplicateContext(
                    evaluationSeed: seed
                )
            let secondContext =
                try PrimeNativeNeuralGateCorrectedReplicateContext(
                    evaluationSeed: seed
                )
            let first = try Input.derive(
                promptText: "same prompt"
            )
            let second = try Input.derive(
                promptText: "same prompt"
            )
            XCTAssertEqual(
                firstContext,
                secondContext
            )
            XCTAssertEqual(first, second)
            XCTAssertEqual(
                first.bindingSHA256,
                second.bindingSHA256
            )
        }
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCorrectedReplicateContext(
                evaluationSeed: 1_619
            )
        )
        XCTAssertThrowsError(
            try Input.derive(
                promptText: ""
            )
        )
        XCTAssertThrowsError(
            try Input.derive(
                promptText:
                    String(
                        repeating: "a",
                        count:
                            Policy
                            .maximumPromptByteCount
                            + 1
                    )
            )
        )
    }

    func testTraceBindsReplicateSeedPolicyAndSupportIdentity()
        throws
    {
        let input = try Input.derive(
            promptText: "bound trace"
        )
        let sequence = try decisions(
            selecting: [
                Policy.endOfSequenceTokenID,
            ]
        )
        let traces = try
            Policy.admittedEvaluationSeeds.map {
                seed in
                try Execution.validate(
                    replicateContext:
                        .init(
                            evaluationSeed: seed
                        ),
                    input: input,
                    decisions: sequence
                )
            }
        XCTAssertEqual(
            traces.count,
            3
        )
        XCTAssertEqual(
            Set(traces.map(\.traceSHA256)).count,
            3
        )
        XCTAssertEqual(
            Set(
                traces.map {
                    $0.invariantRecords()
                        .joined(separator: "\n")
                }
            ).count,
            3
        )
        let first = traces[0]
        let second = traces[1]
        XCTAssertEqual(
            first.input.bindingSHA256,
            second.input.bindingSHA256
        )
        XCTAssertNotEqual(
            first.traceSHA256,
            second.traceSHA256
        )
        XCTAssertNotEqual(
            first.invariantRecords(),
            second.invariantRecords()
        )
        XCTAssertEqual(
            first.traceSHA256,
            "ee917a135e6a7d9759b56531b1c4094713bba0eebd25a0f15a3d74fd5d607f80"
        )
        XCTAssertNotNil(
            first.canonicalTraceData().range(
                of: Data(Policy.policyID.utf8)
            )
        )
        XCTAssertNotNil(
            first.canonicalTraceData().range(
                of:
                    Data(
                        Policy
                            .orderedCompletionSupportSHA256
                            .utf8
                    )
            )
        )
    }

    func testEncodedSplitFamilyCorrelationIDsCannotAffectRawExecution()
        throws
    {
        let input = try Input.derive(
            promptText: "Prompt-only material."
        )
        let context =
            try PrimeNativeNeuralGateCorrectedReplicateContext(
                evaluationSeed: 3_141
            )
        let trace = try Execution.validate(
            replicateContext: context,
            input: input,
            decisions:
                decisions(
                    selecting: [
                        256 + 65,
                        Policy.endOfSequenceTokenID,
                    ]
                )
        )
        let identifiers = [
            "abstention-000001-arithmetic_composition",
            "validation-999999-sequence_ordering",
            "opaque-correlation",
        ]
        let envelopes = try identifiers.map {
            try PrimeNativeNeuralGateCorrectedCorrelationEnvelope(
                correlationID: $0,
                executionInput: input
            )
        }
        XCTAssertEqual(
            Set(
                envelopes.map {
                    $0.executionInput.bindingSHA256
                }
            ),
            [input.bindingSHA256]
        )
        for envelope in envelopes {
            let replay = try Execution.validate(
                replicateContext: context,
                input: envelope.executionInput,
                decisions: trace.decisions
            )
            XCTAssertEqual(
                replay.canonicalTraceData(),
                trace.canonicalTraceData()
            )
            XCTAssertEqual(
                replay.traceSHA256,
                trace.traceSHA256
            )
            XCTAssertEqual(
                replay.generatedTokenIDs,
                trace.generatedTokenIDs
            )
            XCTAssertEqual(
                replay.decisionsExecuted,
                trace.decisionsExecuted
            )
        }
    }

    func testCompletionFeasibilityIsCanonicalButNotFixtureAuthority()
        throws
    {
        let boundary = [
            String(repeating: "a", count: 63),
            "short",
        ]
        XCTAssertEqual(
            try PrimeNativeNeuralGateCorrectedCompletionFeasibility
                .recompute(
                    expectedCompletions: boundary
                )
                .observedCompletionCount,
            2
        )
        let canonical =
            try PrimeNativeNeuralGateCorrectedCompletionFeasibility
            .recompute(
                expectedCompletions: [
                    "e\u{0301}",
                ]
            )
        XCTAssertFalse(
            canonical.allValuesCanonicalNFC
        )
        XCTAssertTrue(
            canonical
                .allValuesFitFixedCapWithEOS
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCorrectedCompletionFeasibility
                .recompute(
                    expectedCompletions: [
                        "short",
                        String(
                            repeating: "b",
                            count: 64
                        ),
                        "never partially admitted",
                    ]
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateCorrectedMechanicsError,
                .completionExceedsFixedCap(index: 1)
            )
        }
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCorrectedCompletionFeasibility
                .recompute(
                    expectedCompletions: []
                )
        )
    }

    func testFixedCapAndEOSDecisionSemantics()
        throws
    {
        let immediate = try execution(
            selecting: [
                Policy.endOfSequenceTokenID,
            ]
        )
        XCTAssertEqual(
            immediate.termination,
            .eos
        )
        XCTAssertEqual(
            immediate.decisionsExecuted,
            1
        )
        XCTAssertTrue(
            immediate.generatedTokenIDs.isEmpty
        )

        let atDecision64 = try execution(
            selecting:
                Array(
                    repeating: 256 + 65,
                    count: 63
                )
                + [
                    Policy.endOfSequenceTokenID,
                ]
        )
        XCTAssertEqual(
            atDecision64.termination,
            .eos
        )
        XCTAssertEqual(
            atDecision64.decisionsExecuted,
            64
        )
        XCTAssertEqual(
            atDecision64.generatedTokenIDs.count,
            63
        )

        let fixed = try execution(
            selecting:
                Array(
                    repeating: 256 + 66,
                    count: 64
                )
        )
        XCTAssertEqual(
            fixed.termination,
            .fixedCap
        )
        XCTAssertEqual(
            fixed.generatedTokenIDs.count,
            64
        )
        XCTAssertFalse(
            fixed.generatedTokenIDs.contains(
                Policy.endOfSequenceTokenID
            )
        )

        XCTAssertThrowsError(
            try execution(
                selecting:
                    Array(
                        repeating: 256 + 65,
                        count: 63
                    )
            )
        )
        XCTAssertThrowsError(
            try execution(
                selecting: [
                    Policy.endOfSequenceTokenID,
                    256 + 65,
                ]
            )
        )
    }

    func testDecisionRequiresFullVocabularyAndUsesAllowedSupportTiePolicy()
        throws
    {
        let tied = try Decision.make(
            ordinal: 1,
            fullVocabularyLogits:
                Array(
                    repeating: 0,
                    count:
                        Policy
                        .fullVocabularyLogitCount
                )
        )
        XCTAssertEqual(
            tied.selectedTokenID,
            Policy.endOfSequenceTokenID
        )
        XCTAssertTrue(
            tied
                .foundationDoubleSelectedLogProbabilityDiagnostic
                .isFinite
        )
        XCTAssertEqual(
            tied.rawFullVocabularyArgmaxTokenID,
            0
        )
        XCTAssertFalse(
            tied
                .rawFullVocabularyAllowedSupportGreedyTokenParity
        )
        XCTAssertTrue(
            tied.rawFullVocabularyArgmaxIsDisallowed
        )
        XCTAssertThrowsError(
            try Decision.make(
                ordinal: 0,
                fullVocabularyLogits:
                    Array(
                        repeating: 0,
                        count:
                            Policy
                            .fullVocabularyLogitCount
                    )
            )
        )
        XCTAssertThrowsError(
            try Decision.make(
                ordinal: 1,
                fullVocabularyLogits:
                    Array(
                        repeating: 0,
                        count:
                            Policy
                            .fullVocabularyLogitCount
                            - 1
                    )
            )
        )
        XCTAssertThrowsError(
            try Decision.make(
                ordinal: 1,
                fullVocabularyLogits:
                    Array(
                        repeating: 0,
                        count:
                            Policy
                            .fullVocabularyLogitCount
                            + 1
                    )
            )
        )
        var nonfinite = Array(
            repeating: Float.zero,
            count:
                Policy.fullVocabularyLogitCount
        )
        nonfinite[3] = .nan
        XCTAssertThrowsError(
            try Decision.make(
                ordinal: 1,
                fullVocabularyLogits: nonfinite
            )
        )
    }

    func testDisallowedLogitChangesFullVocabularyProbabilityWithoutChangingSelection()
        throws
    {
        let baseline = try Decision.make(
            ordinal: 1,
            fullVocabularyLogits:
                logits(
                    selecting:
                        Policy.endOfSequenceTokenID
                )
        )
        var challengedLogits =
            baseline.fullVocabularyLogits
        challengedLogits[0] = 7
        let challenged = try Decision.make(
            ordinal: 1,
            fullVocabularyLogits:
                challengedLogits
        )
        XCTAssertEqual(
            baseline.selectedTokenID,
            Policy.endOfSequenceTokenID
        )
        XCTAssertEqual(
            challenged.selectedTokenID,
            Policy.endOfSequenceTokenID
        )
        XCTAssertLessThan(
            challenged
                .foundationDoubleSelectedLogProbabilityDiagnostic,
            baseline
                .foundationDoubleSelectedLogProbabilityDiagnostic
        )
        XCTAssertEqual(
            challenged.rawFullVocabularyArgmaxTokenID,
            Policy.endOfSequenceTokenID
        )
        XCTAssertTrue(
            challenged
                .rawFullVocabularyAllowedSupportGreedyTokenParity
        )
        XCTAssertFalse(
            challenged.rawFullVocabularyArgmaxIsDisallowed
        )
        XCTAssertGreaterThan(
            challenged
                .foundationDoubleDisallowedTokenProbabilityMassDiagnostic,
            baseline
                .foundationDoubleDisallowedTokenProbabilityMassDiagnostic
        )
        let expected =
            Double(8)
            - Foundation.log(
                Foundation.exp(Double(8))
                    + Foundation.exp(Double(7))
                    + Double(510)
                    * Foundation.exp(Double(-8))
            )
        XCTAssertEqual(
            challenged
                .foundationDoubleSelectedLogProbabilityDiagnostic,
            expected,
            accuracy: 1e-12
        )
        XCTAssertNotEqual(
            challenged.fullVocabularyLogitsSHA256,
            baseline.fullVocabularyLogitsSHA256
        )
    }

    func testRawExecutionAggregatesFullVocabularyWitnessFromEveryDecision()
        throws
    {
        var first = logits(
            selecting: 256 + 65
        )
        first[0] = 9
        let second = logits(
            selecting:
                Policy.endOfSequenceTokenID
        )
        let trace = try Execution.validate(
            replicateContext:
                .init(evaluationSeed: 1_618),
            input:
                .derive(
                    promptText:
                        "full vocabulary witness"
                ),
            decisions: [
                try Decision.make(
                    ordinal: 1,
                    fullVocabularyLogits: first
                ),
                try Decision.make(
                    ordinal: 2,
                    fullVocabularyLogits: second
                ),
            ]
        )
        XCTAssertFalse(
            trace
                .rawFullVocabularyAllowedSupportGreedyTokenParity
        )
        XCTAssertEqual(
            trace.disallowedFullVocabularyArgmaxCount,
            1
        )
        XCTAssertEqual(
            trace
                .maximumFoundationDoubleDisallowedTokenProbabilityMassDiagnostic,
            trace.decisions.map(
                \.foundationDoubleDisallowedTokenProbabilityMassDiagnostic
            ).max()
        )
        XCTAssertGreaterThanOrEqual(
            trace
                .maximumFoundationDoubleDisallowedTokenProbabilityMassDiagnostic,
            0
        )
        XCTAssertLessThanOrEqual(
            trace
                .maximumFoundationDoubleDisallowedTokenProbabilityMassDiagnostic,
            1.000_001
        )
    }

    func testWorstCaseInvariantRecordsRemainWithinStageBDecodeLimits()
        throws
    {
        let trace = try execution(
            selecting:
                Array(
                    repeating: 256 + 65,
                    count:
                        Policy
                        .maximumGenerationDecisions
                )
        )
        let records =
            trace.invariantRecords()
        let limits =
            PrimeNativeNeuralGateReplayDecodeLimits
            .stageB
        let requiredFixtureRowCount =
            PrimeNativeNeuralGateCapabilitySplit
            .allCases
            .map(\.requiredRowCount)
            .reduce(0, +)
        let projectedRecordCount =
            records.count
            * requiredFixtureRowCount
            * Policy.admittedEvaluationSeeds.count
        let projectedAggregateBytes =
            records.reduce(0) {
                $0 + $1.utf8.count
            }
            * requiredFixtureRowCount
            * Policy.admittedEvaluationSeeds.count

        XCTAssertLessThanOrEqual(
            projectedRecordCount,
            limits.maximumRecordCount
        )
        XCTAssertLessThanOrEqual(
            projectedAggregateBytes,
            limits.maximumAggregateRecordBytes
        )
        XCTAssertTrue(
            records.allSatisfy {
                $0.utf8.count
                    <= limits
                    .maximumRecordByteCount
            }
        )
        XCTAssertLessThan(
            trace.canonicalTraceData().count,
            1_024 * 1_024
        )
        XCTAssertEqual(
            trace.decisions.count,
            Policy.maximumGenerationDecisions
        )
    }

    func testTargetSubstitutionRejoinsOnlyAfterRawExecution()
        throws
    {
        let trace = try execution(
            selecting: [
                256 + 65,
                Policy.endOfSequenceTokenID,
            ]
        )
        let sameLength =
            try PrimeNativeNeuralGatePostExecutionRegradeMaterial(
                expectedCompletion: "B"
            )
        let differentLength =
            try PrimeNativeNeuralGatePostExecutionRegradeMaterial(
                expectedCompletion: "longer"
            )
        let matching =
            try PrimeNativeNeuralGatePostExecutionRegradeMaterial(
                expectedCompletion: "A"
            )
        let traceBytes = trace.canonicalTraceData()
        let same =
            PrimeNativeNeuralGatePredictionRegradeObservation
            .recompute(
                execution: trace,
                material: sameLength
            )
        let different =
            PrimeNativeNeuralGatePredictionRegradeObservation
            .recompute(
                execution: trace,
                material: differentLength
            )
        let exact =
            PrimeNativeNeuralGatePredictionRegradeObservation
            .recompute(
                execution: trace,
                material: matching
            )
        XCTAssertEqual(
            trace.canonicalTraceData(),
            traceBytes
        )
        XCTAssertFalse(same.exactMatch)
        XCTAssertFalse(different.exactMatch)
        XCTAssertTrue(exact.exactMatch)
        XCTAssertEqual(
            exact.semanticMatch,
            .unavailable
        )
        XCTAssertEqual(
            Set([
                same.rawExecutionSHA256,
                different.rawExecutionSHA256,
                exact.rawExecutionSHA256,
            ]),
            [trace.traceSHA256]
        )
    }

    func testRegradePreservesInvalidUTF8AndAbstentionTruth()
        throws
    {
        let invalid = try execution(
            selecting: [
                256 + 0xff,
                Policy.endOfSequenceTokenID,
            ]
        )
        let invalidObservation =
            PrimeNativeNeuralGatePredictionRegradeObservation
            .recompute(
                execution: invalid,
                material:
                    try .init(expectedCompletion: "x")
            )
        XCTAssertFalse(
            invalidObservation.outputUTF8Valid
        )
        XCTAssertFalse(
            invalidObservation.exactMatch
        )

        let abstainTokens =
            Array("ABSTAIN\n".utf8).map {
                Int($0) + Policy.byteTokenBase
            }
                + [Policy.endOfSequenceTokenID]
        let abstain = try execution(
            selecting: abstainTokens
        )
        let abstainObservation =
            PrimeNativeNeuralGatePredictionRegradeObservation
            .recompute(
                execution: abstain,
                material:
                    try .init(
                        expectedCompletion:
                            "ABSTAIN\n"
                    )
            )
        XCTAssertTrue(
            abstainObservation.outputUTF8Valid
        )
        XCTAssertTrue(
            abstainObservation.exactMatch
        )
        XCTAssertTrue(
            abstainObservation.predictedAbstention
        )
    }

    func testRegradeUsesNFCAndRequiresEOSForExactness()
        throws
    {
        let decomposed = "e\u{0301}"
        let decomposedTokens =
            Array(decomposed.utf8).map {
                Int($0) + Policy.byteTokenBase
            }
                + [Policy.endOfSequenceTokenID]
        let canonicalTrace = try execution(
            selecting: decomposedTokens
        )
        let canonicalAuthority =
            try PrimeNativeNeuralGatePostExecutionRegradeMaterial(
                expectedCompletion: "\u{00e9}"
            )
        let canonicalObservation =
            PrimeNativeNeuralGatePredictionRegradeObservation
            .recompute(
                execution: canonicalTrace,
                material: canonicalAuthority
            )
        XCTAssertTrue(canonicalObservation.exactMatch)

        let fixedCapText =
            decomposed
            + String(repeating: "a", count: 61)
        XCTAssertEqual(
            fixedCapText.utf8.count,
            64
        )
        let fixedCapTrace = try execution(
            selecting:
                Array(fixedCapText.utf8).map {
                    Int($0) + Policy.byteTokenBase
                }
        )
        let fixedCapAuthority =
            try PrimeNativeNeuralGatePostExecutionRegradeMaterial(
                expectedCompletion: fixedCapText
            )
        XCTAssertFalse(
            PrimeNativeNeuralGatePredictionRegradeObservation
                .recompute(
                    execution: fixedCapTrace,
                    material: fixedCapAuthority
                )
                .exactMatch
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGatePostExecutionRegradeMaterial(
                expectedCompletion:
                    String(repeating: "x", count: 64)
            )
        )
    }

    func testWeightedLossKnownAnswerAndSingleton()
        throws
    {
        let rows = [
            try PrimeNativeNeuralGateWeightedLossRow(
                targetTokenCount: 1,
                crossEntropyBefore: 2,
                crossEntropyAfter: 2
            ),
            try PrimeNativeNeuralGateWeightedLossRow(
                targetTokenCount: 2,
                crossEntropyBefore: 4,
                crossEntropyAfter: 4
            ),
        ]
        let result =
            try PrimeNativeNeuralGateWeightedLossStatistics
            .recompute(rows: rows)
        XCTAssertEqual(result.rowCount, 2)
        XCTAssertEqual(
            result.totalTargetTokenCount,
            3
        )
        XCTAssertEqual(
            result.weightedMeanAfter,
            10.0 / 3.0,
            accuracy: 1e-12
        )
        XCTAssertEqual(
            result.effectiveRows,
            9.0 / 5.0,
            accuracy: 1e-12
        )
        XCTAssertEqual(
            result.weightedVarianceAfter,
            2,
            accuracy: 1e-12
        )
        XCTAssertEqual(
            result.standardErrorAfter,
            sqrt(10.0 / 9.0),
            accuracy: 1e-12
        )

        let singleton =
            try PrimeNativeNeuralGateWeightedLossStatistics
            .recompute(
                rows: [
                    try .init(
                        targetTokenCount: 4,
                        crossEntropyBefore: 3,
                        crossEntropyAfter: 2
                    ),
                ]
            )
        XCTAssertEqual(
            singleton
                .unbiasedVarianceDenominator,
            0
        )
        XCTAssertEqual(
            singleton.weightedVarianceAfter,
            0
        )
        XCTAssertEqual(
            singleton.standardErrorAfter,
            0
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateWeightedLossRow(
                targetTokenCount: 0,
                crossEntropyBefore: 1,
                crossEntropyAfter: 1
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateWeightedLossRow(
                targetTokenCount: 1,
                crossEntropyBefore: .nan,
                crossEntropyAfter: 1
            )
        )
    }

    func testFixedPromptBehavioralAndBitwiseSemantics()
        throws
    {
        var first = Array(
            repeating: Float(-4),
            count: Policy.fullVocabularyLogitCount
        )
        first[0] = 3
        first[1] = 1
        var replay = first
        replay[0] = 3.1
        let behavioral =
            try PrimeNativeNeuralGateFixedPromptReplayObservation
            .recompute(
                firstFloatBitPatterns:
                    first.map(\.bitPattern),
                replayFloatBitPatterns:
                    replay.map(\.bitPattern)
            )
        XCTAssertTrue(
            behavioral.greedyTokenStable
        )
        XCTAssertTrue(
            behavioral.behavioralReplayExact
        )
        XCTAssertFalse(
            behavioral.bitwiseReplayExact
        )

        let bitwise =
            try PrimeNativeNeuralGateFixedPromptReplayObservation
            .recompute(
                firstFloatBitPatterns:
                    first.map(\.bitPattern),
                replayFloatBitPatterns:
                    first.map(\.bitPattern)
            )
        XCTAssertTrue(bitwise.behavioralReplayExact)
        XCTAssertTrue(bitwise.bitwiseReplayExact)

        var tie = Array(
            repeating: Float(-4),
            count: Policy.fullVocabularyLogitCount
        )
        tie[0] = 1
        tie[1] = 1
        let tied =
            try PrimeNativeNeuralGateFixedPromptReplayObservation
            .recompute(
                firstFloatBitPatterns:
                    tie.map(\.bitPattern),
                replayFloatBitPatterns:
                    tie.map(\.bitPattern)
            )
        XCTAssertFalse(tied.behavioralReplayExact)

        var strictFirst = Array(
            repeating: Float(-4),
            count: Policy.fullVocabularyLogitCount
        )
        strictFirst[0] = 2
        strictFirst[1] = 0
        var strictReplay = strictFirst
        strictReplay[0] = 1.5
        strictReplay[1] = 0.5
        let strict =
            try PrimeNativeNeuralGateFixedPromptReplayObservation
            .recompute(
                firstFloatBitPatterns:
                    strictFirst.map(\.bitPattern),
                replayFloatBitPatterns:
                    strictReplay.map(\.bitPattern)
        )
        XCTAssertFalse(strict.behavioralReplayExact)
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateFixedPromptReplayObservation
                .recompute(
                    firstFloatBitPatterns:
                        Array(first.dropLast())
                        .map(\.bitPattern),
                    replayFloatBitPatterns:
                        Array(replay.dropLast())
                        .map(\.bitPattern)
                )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateFixedPromptReplayObservation
                .recompute(
                    firstFloatBitPatterns:
                        (first + [0]).map(\.bitPattern),
                    replayFloatBitPatterns:
                        (replay + [0]).map(\.bitPattern)
                )
        )
    }

    func testCapabilityThresholdMatrixIsRecomputedAndRemainsUnavailable()
        throws
    {
        func rows(
            split:
                PrimeNativeNeuralGateCapabilitySplit,
            correctedPassCount: Int,
            zeroShotPassCount: Int
        ) -> [PrimeNativeNeuralGateCapabilityRow] {
            (0 ..< split.requiredRowCount).map {
                index in
                PrimeNativeNeuralGateCapabilityRow(
                    split: split,
                    zeroShotExact:
                        index < zeroShotPassCount,
                    correctedExact:
                        index < correctedPassCount,
                    expectedAbstention:
                        split == .abstention,
                    correctedAbstention:
                        split == .abstention
                )
            }
        }
        let allRows =
            rows(
                split: .validation,
                correctedPassCount: 0,
                zeroShotPassCount: 0
            )
            + rows(
                split: .combinationHoldout,
                correctedPassCount: 3_277,
                zeroShotPassCount: 2_000
            )
            + rows(
                split: .outOfDistribution,
                correctedPassCount: 2_868,
                zeroShotPassCount: 2_000
            )
            + rows(
                split: .mutation,
                correctedPassCount: 3_277,
                zeroShotPassCount: 2_000
            )
            + rows(
                split: .abstention,
                correctedPassCount: 2_048,
                zeroShotPassCount: 0
            )
        let result =
            try PrimeNativeNeuralGateCapabilityObservation
            .recompute(rows: allRows)
        XCTAssertEqual(
            result.totalRowCount,
            18_432
        )
        XCTAssertTrue(result.thresholdsSatisfied)
        XCTAssertFalse(
            result
                .sourceBoundRowIdentityAndCoverageEstablished
        )
        XCTAssertEqual(
            result.modelCapability,
            .unavailable
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCapabilityObservation
                .recompute(
                    rows: Array(allRows.dropLast())
                )
        )
    }

    func testCountLabelNeverSubstitutesForAllTenVerdict()
        throws
    {
        let IDs =
            PrimeNativeNeuralGateCountDerivedVerdict
            .orderedCriticalLegIDs
        let three = try
            PrimeNativeNeuralGateCountDerivedVerdict
            .recompute(
                legs: IDs.enumerated().map {
                    .init(
                        legID: $0.element,
                        passed: $0.offset < 3,
                        detail: "raw recomputation"
                    )
                }
            )
        XCTAssertEqual(
            three.countDerivedLabel,
            "independentThreePlus(3)"
        )
        XCTAssertEqual(
            three.mechanicsOutcome,
            .abstain
        )
        XCTAssertFalse(
            three
                .distinctImplementationFamiliesEstablished
        )
        XCTAssertFalse(
            three
                .agentContractKitFourTierAuditPerformed
        )

        let all = try
            PrimeNativeNeuralGateCountDerivedVerdict
            .recompute(
                legs: IDs.map {
                    .init(
                        legID: $0,
                        passed: true,
                        detail: "raw recomputation"
                    )
                }
            )
        XCTAssertEqual(all.passingCount, 10)
        XCTAssertEqual(
            all.mechanicsOutcome,
            .grounded
        )
        XCTAssertEqual(
            all.modelCapability,
            .unavailable
        )
        XCTAssertFalse(
            all
                .sourceBoundCriticalLegEvidenceEstablished
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCountDerivedVerdict
                .recompute(
                    legs: Array(all.legs.dropLast())
                )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCountDerivedVerdict
                .recompute(
                    legs: Array(all.legs.reversed())
                )
        )
    }

    func testFifteenMutationObservationIDsValidateDivergenceAndRestoration()
        throws
    {
        XCTAssertEqual(
            PrimeNativeNeuralGateCorrectedMutationID
                .allCases.count,
            15
        )
        let observations = try
            PrimeNativeNeuralGateCorrectedMutationID
            .allCases.map { mutation in
                try PrimeNativeNeuralGateCorrectedMutationObservation
                    .recompute(
                        mutationID: mutation,
                        baselineRecords: [
                            "baseline-record",
                        ],
                        mutatedRecords: [
                            "baseline-record",
                            "mutation=\(mutation.rawValue)",
                        ],
                        restoredRecords: [
                            "baseline-record",
                        ],
                        observedFailedLegIDs: [
                            mutation.expectedFailedLeg,
                        ]
                    )
            }
        let sweep = try
            PrimeNativeNeuralGateCorrectedMutationSweepObservation
            .recompute(
                observations: observations
            )
        XCTAssertTrue(sweep.catalogComplete)
        XCTAssertTrue(
            sweep.observations.allSatisfy {
                !$0.independentMutationExecutionObserved
                    && !$0.independentDetectorObserved
            }
        )
        XCTAssertEqual(
            sweep.observations.map(\.mutationID),
            PrimeNativeNeuralGateCorrectedMutationID
                .allCases
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCorrectedMutationSweepObservation
                .recompute(
                    observations:
                        Array(observations.dropLast())
                )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCorrectedMutationObservation
                .recompute(
                    mutationID:
                        .fixedCapDrift,
                    baselineRecords: ["same"],
                    mutatedRecords: ["same"],
                    restoredRecords: ["same"],
                    observedFailedLegIDs: [
                        PrimeNativeNeuralGateCorrectedMutationID
                            .fixedCapDrift
                            .expectedFailedLeg,
                    ]
                )
        )
    }

    func testPureTargetClosureContainsNoTrapProcessIOOrExternalRuntimeAuthority()
        throws
    {
        let files =
            try correctedTargetClosureSwiftFiles()
        XCTAssertFalse(files.isEmpty)
        let source = try files.map {
            try String(
                contentsOf: $0,
                encoding: .utf8
            )
        }.joined(separator: "\n")
        let forbidden = [
            "Process(",
            "NSTask",
            "posix_spawn",
            "dlopen",
            " system(",
            "popen(",
            "URLSession",
            "FileHandle",
            "FileManager",
            "try" + "!",
            "fatalError(",
            "precondition(",
            "preconditionFailure(",
            "assert(",
            "Python",
            "ErgenticsPrimeRuntime",
            "NeuralKit",
            "PMHNP",
            "MLX",
        ]
        for token in forbidden {
            XCTAssertFalse(
                source.contains(token),
                "forbidden corrected authority: \(token)"
            )
        }
        let package = try String(
            contentsOfFile: "Package.swift",
            encoding: .utf8
        )
        let compact = package.filter {
            !$0.isWhitespace
        }
        XCTAssertTrue(
            compact.contains(
                #".target(name:"PrimeNativeNeuralGateCorrectedMechanics",dependencies:["PrimeNativeNeuralGateReplayMechanics",])"#
            )
        )
    }

    func testPurePrimitivesCannotConstructStageBReceiptOrExecutionPass()
        throws
    {
        let source =
            try correctedTargetClosureSwiftFiles()
            .map {
                try String(
                    contentsOf: $0,
                    encoding: .utf8
                )
            }
            .joined(separator: "\n")
        XCTAssertFalse(
            source.contains("StageBReceipt")
        )
        XCTAssertFalse(
            source.contains("executionAuthorized")
        )
        XCTAssertFalse(
            source.contains("productUseAuthorized")
        )
        XCTAssertFalse(
            source.contains("PromptOnlySolver")
        )
        XCTAssertFalse(
            source.contains("-> Verdict")
        )
    }

    func testLiveMechanicsValuesRemainNonCodable()
    {
        let types: [Any.Type] = [
            PrimeNativeNeuralGatePromptOnlyExecutionInput
                .self,
            PrimeNativeNeuralGateCorrectedCorrelationEnvelope
                .self,
            PrimeNativeNeuralGateCompletionDecision
                .self,
            PrimeNativeNeuralGateRawExecution
                .self,
            PrimeNativeNeuralGatePostExecutionRegradeMaterial
                .self,
            PrimeNativeNeuralGatePredictionRegradeObservation
                .self,
            PrimeNativeNeuralGateWeightedLossRow
                .self,
            PrimeNativeNeuralGateWeightedLossStatistics
                .self,
            PrimeNativeNeuralGateFixedPromptReplayObservation
                .self,
            PrimeNativeNeuralGateCapabilityRow
                .self,
            PrimeNativeNeuralGateCapabilitySplitObservation
                .self,
            PrimeNativeNeuralGateCapabilityObservation
                .self,
            PrimeNativeNeuralGateCriticalLegObservation
                .self,
            PrimeNativeNeuralGateCountDerivedVerdict
                .self,
            PrimeNativeNeuralGateCorrectedMutationObservation
                .self,
            PrimeNativeNeuralGateCorrectedMutationSweepObservation
                .self,
        ]
        for type in types {
            XCTAssertFalse(
                type is any Codable.Type,
                "\(type) must remain a live non-artifact value"
            )
        }
    }
}
