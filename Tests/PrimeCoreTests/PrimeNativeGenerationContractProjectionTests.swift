import Foundation
import XCTest
@testable import PrimeCore

final class PrimeNativeGenerationContractProjectionTests:
    XCTestCase
{
    func testFrozenPlanBindsExactlyThreeOperationalSourcePins()
        throws
    {
        let plan =
            PrimeNativeGenerationContractPlan.frozenV1

        try plan.validate()
        XCTAssertEqual(plan.requiredSourcePinCount, 3)
        XCTAssertTrue(
            plan
                .operationalSemanticsClaimRequiresAllSourcePins
        )
        XCTAssertTrue(
            plan
                .sourceBindingsAreDeclaredContentAuditedLineage
        )
        XCTAssertFalse(
            plan.sourceBlobEvidenceResolvedAtExecution
        )
        XCTAssertEqual(
            plan.freshVerifierSourceIdentityPolicy,
            "same_source_identity_release_binary_required_v1"
        )
        XCTAssertEqual(
            plan.companionRevision,
            "163fc100710ece48119bc25954452d10f6a84f7f"
        )
        XCTAssertEqual(
            plan.companionTreeOID,
            "9009daa4f8a07fbd5897e00b9571cef44ec292db"
        )
        XCTAssertEqual(
            plan.sourceBindings,
            [
                PrimeNativeGenerationContractSourceBinding(
                    role: .contractAuthority,
                    repositoryRelativePath:
                        "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "027a25b49dde1acfb4cd8af970e05ecd8241f427",
                    byteCount: 216_815,
                    sha256:
                        "8706343bf93c1dac70f5c263f7111667574da751cd27d6c3321a92fd822f063f"
                ),
                PrimeNativeGenerationContractSourceBinding(
                    role:
                        .independentAcceptanceGate,
                    repositoryRelativePath:
                        "neural-kit/Sources/NeuralKit/PrimeNeuralNativeLanguageVerifyAbstainGate.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "795fff7c458ec68ba4562b6cd1c674fe8de7ffc4",
                    byteCount: 368_918,
                    sha256:
                        "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6"
                ),
                PrimeNativeGenerationContractSourceBinding(
                    role: .operationalSwiftExecutor,
                    repositoryRelativePath:
                        "prime-runtime/Sources/PrimeNativeLanguageSwiftCanary/main.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "94227842cdff73434c926527a6081aaf20f37155",
                    byteCount: 174_006,
                    sha256:
                        "7a3ba9477a7ac82dccfe6dcc7ec09af738b40298cdab6b259ddf1e9d36ec15b4"
                ),
            ]
        )
        XCTAssertEqual(
            PrimeNativeGenerationContractPlan
                .requiredSourcePaths,
            plan.sourceBindings.map(
                \.repositoryRelativePath
            )
        )
    }

    func testOrderedSupportHashAndBothTieRulesAreExact()
        throws
    {
        let projection =
            PrimeNativeGenerationContractProjection
            .frozenV1

        try projection.validate()
        let expected = [70] + Array(256 ... 511)
        XCTAssertEqual(
            projection.allowedCompletionTokenIDs,
            expected
        )
        XCTAssertEqual(
            PrimeNativeGenerationContractProjection
                .allowedCompletionTokenSetSHA256(
                    expected
                ),
            "e3c1f6e4fc7b0329c2df97af2a32bff273d5534d7ccf54eaa1ef00b78b0d1768"
        )
        XCTAssertEqual(
            projection.allowedCompletionTokenSetSHA256,
            "e3c1f6e4fc7b0329c2df97af2a32bff273d5534d7ccf54eaa1ef00b78b0d1768"
        )
        XCTAssertNotEqual(
            PrimeNativeGenerationContractProjection
                .allowedCompletionTokenSetSHA256(
                    Array(expected.reversed())
                ),
            projection.allowedCompletionTokenSetSHA256
        )
        XCTAssertEqual(
            projection.greedyComparatorExpression,
            "score[left] < score[right]"
        )
        XCTAssertEqual(
            projection.greedyEqualLogitTiePolicy,
            "first_ordered_support_entry_wins_equal_logit_tie_eos70_v1"
        )
        XCTAssertEqual(
            projection
                .rawFullVocabularyEqualLogitTiePolicy,
            "first_vocabulary_token_wins_equal_logit_tie_token0_v1"
        )
        XCTAssertTrue(
            projection.allowedSupportOrderOperational
        )
    }

    func testKVCacheAndFullVocabularyWitnessMechanicsAreExactButUnobserved()
        throws
    {
        let projection =
            PrimeNativeGenerationContractProjection
            .frozenV1
        let cache = projection.kvCacheMechanics
        let witness = projection.fullVocabularyWitness

        try projection.validate()
        try cache.validateFrozenV1()
        try witness.validateFrozenV1()
        XCTAssertTrue(cache.generationUsesKVCache)
        XCTAssertEqual(
            cache.decodeStepInputTokenCount,
            1
        )
        XCTAssertEqual(
            cache
                .singleStepMaximumLogitDeltaUpperBound,
            1e-4
        )
        XCTAssertEqual(
            cache
                .singleStepGreedyComparisonDomain,
            "full_vocabulary_512_v1"
        )
        XCTAssertEqual(
            cache.singleStepFixtureTokenIDs,
            [1, 321, 322, 323, 324, 325, 326, 70]
        )
        XCTAssertEqual(
            cache
                .multiStepMaximumLogitDeltaUpperBound,
            1e-4
        )
        XCTAssertEqual(
            cache.multiStepComparedDecisionCount,
            6
        )
        XCTAssertEqual(
            cache.multiStepContinuationDecisionCounts,
            [2, 4]
        )
        XCTAssertEqual(
            cache.multiStepPromptTokenIDPaths,
            [
                [1, 300, 301],
                [1, 310, 311, 312, 313],
            ]
        )
        XCTAssertEqual(
            cache.multiStepContinuationTokenIDPaths,
            [
                [321, 70],
                [341, 342, 343, 70],
            ]
        )
        XCTAssertTrue(cache.multiStepUnevenEOSRequired)
        XCTAssertFalse(
            cache.cacheParityWitnessValuesObserved
        )
        XCTAssertEqual(
            witness
                .logProbabilityExtractionPrecisionPolicy,
            "mlx_logsoftmax_values_extracted_as_float32_then_promoted_to_double_v1"
        )
        XCTAssertEqual(
            witness.disallowedTokenSetPolicy,
            "token_ids_0_through_511_minus_allowed_completion_support_v1"
        )
        XCTAssertEqual(
            witness
                .maximumDisallowedProbabilityMassAcceptanceUpperBound,
            1.000_001
        )
        XCTAssertFalse(
            witness.witnessValuesRecomputedFromLogits
        )
    }

    func testSchema2GeneratedFieldsRemainCamelCaseAndSchema4FieldsRemainExact()
        throws
    {
        let raw =
            PrimeNativeGenerationRawShardFieldProjection
            .frozenV1
        try raw.validateFrozenV1()
        XCTAssertEqual(raw.shardSchemaVersion, "2")
        XCTAssertEqual(
            raw.generatedFields,
            [
                "text",
                "tokenIDs",
                "tokenLogProbabilities",
                "meanLogProbability",
                "terminatedByEOS",
                "terminationReason",
                "utf8Valid",
                "eosLogProbability",
                "rawFullVocabularyAllowedSupportGreedyTokenParity",
                "disallowedFullVocabularyArgmaxCount",
                "maximumDisallowedTokenProbabilityMass",
                "latencySeconds",
            ]
        )
        XCTAssertFalse(
            raw.generatedFields.contains(
                "token_ids"
            )
        )

        let regrade =
            PrimeNativeGenerationSchema4RegradeFieldProjection
            .frozenV1
        try regrade.validateFrozenV1()
        XCTAssertEqual(regrade.reportSchemaVersion, "4")
        XCTAssertEqual(
            regrade.orderedRecordFields,
            [
                "row_id",
                "corpus_row_sha256",
                "evaluation_row_sha256",
                "split",
                "semantic_family",
                "invariant_ids",
                "mutation_id",
                "abstention_reason",
                "prompt",
                "prompt_token_ids",
                "target",
                "target_token_ids",
                "prompt_grouping_key_id",
                "prompt_grouping_key",
                "generation_decision_budget",
                "allowed_completion_token_set_sha256",
                "eos_available_at_every_decision",
                "target_independent_decision_budget",
                "zero_shot_decisions_executed",
                "zero_shot_prediction",
                "zero_shot_prediction_token_ids",
                "zero_shot_mean_log_probability",
                "zero_shot_token_log_probabilities",
                "zero_shot_terminated_by_eos",
                "zero_shot_termination_reason",
                "zero_shot_utf8_valid",
                "zero_shot_eos_log_probability",
                "zero_shot_raw_full_vocabulary_allowed_support_greedy_token_parity",
                "zero_shot_disallowed_full_vocabulary_argmax_count",
                "zero_shot_maximum_disallowed_token_probability_mass",
                "zero_shot_exact_match",
                "zero_shot_semantic_verifier_pass",
                "zero_shot_abstention_decision",
                "zero_shot_latency_seconds",
                "trained_prediction",
                "trained_prediction_token_ids",
                "trained_mean_log_probability",
                "trained_token_log_probabilities",
                "trained_terminated_by_eos",
                "trained_termination_reason",
                "trained_utf8_valid",
                "trained_eos_log_probability",
                "trained_raw_full_vocabulary_allowed_support_greedy_token_parity",
                "trained_disallowed_full_vocabulary_argmax_count",
                "trained_maximum_disallowed_token_probability_mass",
                "trained_exact_match",
                "trained_semantic_verifier_pass",
                "trained_abstention_decision",
                "trained_latency_seconds",
                "trained_decisions_executed",
            ]
        )
        XCTAssertEqual(
            Set(regrade.orderedRecordFields).count,
            regrade.orderedRecordFields.count
        )
    }

    func testFrozenPlanAndEveryNonclaimRejectMutation()
        throws
    {
        let plan =
            PrimeNativeGenerationContractPlan.frozenV1
        try plan.validate()
        for mutation in [
            ("required_source_pin_count", 2 as Any),
            (
                "existing_adapter_mutation_authorized",
                true as Any
            ),
            (
                "companion_execution_authorized",
                true as Any
            ),
            (
                "source_blob_evidence_resolved_at_execution",
                true as Any
            ),
            (
                "fresh_verifier_source_identity_policy",
                "any_future_source_v0" as Any
            ),
        ] {
            let drifted:
                PrimeNativeGenerationContractPlan =
                try topLevelMutation(
                    plan,
                    key: mutation.0,
                    value: mutation.1
                )
            XCTAssertThrowsError(
                try drifted.validate(),
                "plan mutation must fail: \(mutation.0)"
            )
        }

        let nonclaims =
            PrimeNativeGenerationContractNonclaims
            .frozenV1
        try nonclaims.validateFrozenV1()
        let object = try jsonObject(nonclaims)
        for (key, value) in object {
            guard value is Bool else { continue }
            XCTAssertEqual(
                value as? Bool,
                false,
                "nonclaim must remain false: \(key)"
            )
            let expanded:
                PrimeNativeGenerationContractNonclaims =
                try topLevelMutation(
                    nonclaims,
                    key: key,
                    value: true
                )
            XCTAssertThrowsError(
                try expanded.validateFrozenV1(),
                "nonclaim expansion must fail: \(key)"
            )
        }
    }

    func testPromptOnlyRequestIsTargetFreeAndBudgetIsContractBound()
        throws
    {
        let request =
            try PrimeNativePromptOnlyGenerationRequest(
                rowID: "row-1",
                seed: 1_618,
                promptText: "é?"
            )
        let promptByteTokens =
            PrimeNativeByteTokenizer.encode("é?")

        XCTAssertEqual(
            request.promptTokenIDs,
            [PrimeNativeByteTokenizer
                .beginningOfSequenceTokenID]
                + promptByteTokens
        )
        XCTAssertEqual(
            request.promptGroupingKey,
            promptByteTokens.count
        )
        let requestObject = try jsonObject(request)
        XCTAssertEqual(
            Set(requestObject.keys),
            Set(
                PrimeNativeGenerationPromptOnlyFieldProjection
                    .frozenV1.primeRequestFields
            )
        )
        XCTAssertTrue(
            Set(requestObject.keys).isDisjoint(
                with: Set(
                    PrimeNativeGenerationPromptOnlyFieldProjection
                        .frozenV1
                        .forbiddenTargetAndRegradeFields
                )
            )
        )
        let projection =
            PrimeNativeGenerationContractProjection
            .frozenV1
        XCTAssertEqual(
            projection.maximumGenerationTokenDecisions,
            64
        )
        XCTAssertTrue(
            projection.targetIndependentDecisionBudget
        )
        XCTAssertTrue(
            projection.eosAvailableAtEveryDecision
        )
    }

    func testImmediateEOSAndPositiveFiniteLogProbabilityAreAccepted()
        throws
    {
        let observation =
            try PrimeNativeHistoricalRawGenerationObservation(
                text: "",
                tokenIDs: [],
                tokenLogProbabilities: [],
                meanLogProbability: 0.25,
                terminatedByEOS: true,
                terminationReason: .eos,
                utf8Valid: true,
                eosLogProbability: 0.25,
                rawFullVocabularyAllowedSupportGreedyTokenParity:
                    true,
                disallowedFullVocabularyArgmaxCount:
                    0,
                maximumDisallowedTokenProbabilityMass:
                    0.2,
                latencySeconds: 0.001
            )

        try observation.validate(
            declaredDecisionsExecuted: 1
        )
        XCTAssertEqual(observation.decisionsExecuted, 1)
        XCTAssertEqual(
            PrimeNativeGenerationContractProjection
                .frozenV1
                .logProbabilityValidationPolicy,
            "finite_only_v1"
        )
        XCTAssertFalse(
            PrimeNativeGenerationContractProjection
                .frozenV1
                .primeNonPositiveLogProbabilityHardeningApplied
        )
    }

    func testFixedCapRequiresExactly64ByteDecisions()
        throws
    {
        let observation = try fixedCapObservation()

        try observation.validate(
            declaredDecisionsExecuted: 64
        )
        XCTAssertEqual(observation.tokenIDs.count, 64)
        XCTAssertEqual(observation.decisionsExecuted, 64)
        XCTAssertEqual(
            observation.terminationReason,
            .fixedCap
        )
        XCTAssertNil(observation.eosLogProbability)
    }

    func testInvalidUTF8IsPreservedAsTokensWithNilText()
        throws
    {
        let observation =
            try PrimeNativeHistoricalRawGenerationObservation(
                text: nil,
                tokenIDs: [511],
                tokenLogProbabilities: [-0.5],
                meanLogProbability: -0.35,
                terminatedByEOS: true,
                terminationReason: .eos,
                utf8Valid: false,
                eosLogProbability: -0.2,
                rawFullVocabularyAllowedSupportGreedyTokenParity:
                    true,
                disallowedFullVocabularyArgmaxCount:
                    0,
                maximumDisallowedTokenProbabilityMass:
                    0.1,
                latencySeconds: 0.01
            )

        try observation.validate()
        XCTAssertNil(observation.text)
        XCTAssertFalse(observation.utf8Valid)
        XCTAssertEqual(observation.tokenIDs, [511])
    }

    func testGeneratedTextUsesDonorCanonicalStringEqualityNotByteEquality()
        throws
    {
        let decomposedBytes = Array("e\u{301}".utf8)
        let tokenIDs = decomposedBytes.map {
            Int($0)
                + PrimeNativeByteTokenizer
                .byteTokenRange.lowerBound
        }
        let observation =
            try PrimeNativeHistoricalRawGenerationObservation(
                text: "\u{e9}",
                tokenIDs: tokenIDs,
                tokenLogProbabilities:
                    Array(
                        repeating: -0.5,
                        count: tokenIDs.count
                    ),
                meanLogProbability: -0.5,
                terminatedByEOS: true,
                terminationReason: .eos,
                utf8Valid: true,
                eosLogProbability: -0.5,
                rawFullVocabularyAllowedSupportGreedyTokenParity:
                    true,
                disallowedFullVocabularyArgmaxCount:
                    0,
                maximumDisallowedTokenProbabilityMass:
                    0.1,
                latencySeconds: 0.01
            )

        try observation.validate()
        XCTAssertNotEqual(
            Array(try XCTUnwrap(observation.text).utf8),
            decomposedBytes
        )
        XCTAssertEqual(
            PrimeNativeGenerationContractProjection
                .frozenV1
                .generatedTextComparisonPolicy,
            "swift_string_canonical_equivalence_against_utf8_decoded_token_bytes_v1"
        )
        XCTAssertFalse(
            PrimeNativeGenerationContractProjection
                .frozenV1
                .primeByteExactGeneratedTextHardeningApplied
        )
    }

    func testOptionalMissingAndNullDecodeEquallyWhileUnknownKeysFailClosed()
        throws
    {
        let observation =
            try invalidUTF8FixedCapObservation()
        let missingData =
            try PrimeCanonicalJSON.encode(observation)
        let missingObject =
            try XCTUnwrap(
                JSONSerialization.jsonObject(
                    with: missingData
                ) as? [String: Any]
            )
        XCTAssertNil(missingObject["text"])
        XCTAssertNil(missingObject["eosLogProbability"])

        var explicitNullObject = missingObject
        explicitNullObject["text"] = NSNull()
        explicitNullObject["eosLogProbability"] =
            NSNull()
        let explicitNullData =
            try JSONSerialization.data(
                withJSONObject: explicitNullObject,
                options: [.sortedKeys]
            )
        let decodedMissing = try JSONDecoder().decode(
            PrimeNativeHistoricalRawGenerationObservation
                .self,
            from: missingData
        )
        let decodedNull = try JSONDecoder().decode(
            PrimeNativeHistoricalRawGenerationObservation
                .self,
            from: explicitNullData
        )
        XCTAssertEqual(decodedMissing, decodedNull)
        XCTAssertEqual(decodedMissing, observation)

        let projection =
            PrimeNativeGenerationContractProjection
            .frozenV1
        XCTAssertEqual(
            projection.optionalNilKeyEncoding,
            "omitted"
        )
        XCTAssertTrue(
            projection
                .optionalDecoderMissingAndNullEquivalent
        )
        XCTAssertEqual(
            projection.donorUnknownKeyDecodingPolicy,
            "ignored"
        )
        XCTAssertEqual(
            projection
                .primeStrictRawValidatorUnknownKeyPolicy,
            "rejected"
        )

        var unknownObject = missingObject
        unknownObject["target"] = "leak"
        let unknownData =
            try JSONSerialization.data(
                withJSONObject: unknownObject,
                options: [.sortedKeys]
            )
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                PrimeNativeHistoricalRawGenerationObservation
                    .self,
                from: unknownData
            )
        )
    }

    func testRawObservationRejectsMeanCountTerminationLatencyAndSupportMutations()
        throws
    {
        let immediateEOS =
            try PrimeNativeHistoricalRawGenerationObservation(
                text: "",
                tokenIDs: [],
                tokenLogProbabilities: [],
                meanLogProbability: -0.2,
                terminatedByEOS: true,
                terminationReason: .eos,
                utf8Valid: true,
                eosLogProbability: -0.2,
                rawFullVocabularyAllowedSupportGreedyTokenParity:
                    true,
                disallowedFullVocabularyArgmaxCount:
                    0,
                maximumDisallowedTokenProbabilityMass:
                    0.1,
                latencySeconds: 0.01
            )
        let fixedCap = try fixedCapObservation()

        for (name, source, changes) in [
            (
                "mean",
                immediateEOS,
                ["meanLogProbability": -0.1 as Any]
            ),
            (
                "count",
                fixedCap,
                [
                    "tokenLogProbabilities":
                        Array(repeating: -0.5, count: 63)
                        as Any,
                ]
            ),
            (
                "termination",
                immediateEOS,
                ["terminationReason": "fixed_cap" as Any]
            ),
            (
                "latency",
                immediateEOS,
                ["latencySeconds": 0.0 as Any]
            ),
            (
                "token support",
                fixedCap,
                [
                    "tokenIDs":
                        [70]
                        + Array(repeating: 321, count: 63)
                        as Any,
                ]
            ),
            (
                "support parity",
                immediateEOS,
                [
                    "disallowedFullVocabularyArgmaxCount":
                        1 as Any,
                ]
            ),
            (
                "support mass",
                immediateEOS,
                [
                    "maximumDisallowedTokenProbabilityMass":
                        1.1 as Any,
                ]
            ),
        ] {
            XCTAssertThrowsError(
                try mutatedRawObservation(
                    source,
                    changes: changes
                ),
                "raw mutation must fail: \(name)"
            )
        }
        XCTAssertThrowsError(
            try immediateEOS.validate(
                declaredDecisionsExecuted: 2
            )
        )
    }

    func testProjectionMutationSweepExactlyCoversAllCases()
        throws
    {
        let records =
            try PrimeNativeGenerationContractOverlay
            .mutationSweep()

        XCTAssertEqual(
            records.map(\.mutation),
            PrimeNativeGenerationContractMutation.allCases
        )
        XCTAssertEqual(
            records,
            PrimeNativeGenerationContractMutation
                .frozenDetectedAndRestoredRecords
        )
        XCTAssertEqual(
            Set(records.map(\.detectorID)).count,
            records.count
        )
        try records.forEach {
            try $0.validate()
        }
        for record in records {
            let undetected =
                PrimeNativeGenerationContractMutationRecord(
                    mutation: record.mutation,
                    detectorID: record.detectorID,
                    detected: false,
                    restored: true,
                    independentScientificOracleClaimed:
                        false
                )
            XCTAssertThrowsError(
                try undetected.validate()
            )
            let expanded =
                PrimeNativeGenerationContractMutationRecord(
                    mutation: record.mutation,
                    detectorID: record.detectorID,
                    detected: true,
                    restored: true,
                    independentScientificOracleClaimed:
                        true
                )
            XCTAssertThrowsError(
                try expanded.validate()
            )
        }
    }

    func testOverlayPlanBindsExactParentAndKeepsBehavioralClaimsFalse()
        throws
    {
        let plan =
            PrimeNativeGenerationContractOverlayPlan
            .frozenV1

        try plan.validate()
        XCTAssertEqual(
            plan.parentAdapterReceiptSHA256,
            "0c5cb638a5ba4e157f9e9a62b648862fe5511841e43f18b87c9d94d5b4b3a867"
        )
        XCTAssertEqual(
            plan.parentAdapterProjectionSHA256,
            "ddba956b7b4f7e3996fde6d8f11046ec3a222ef62467b806b5170887ef7620bf"
        )
        XCTAssertEqual(
            plan.parentAdapterSourceRevision,
            "69e65f2d23fe790bec2336e0d2c8686e1fd4daaf"
        )
        XCTAssertEqual(
            plan.parentAdapterSourceTreeOID,
            "08a7d58b2f0f41962642ba2faeda547962bd2449"
        )
        XCTAssertEqual(
            plan.parentAdapterSourceIdentitySHA256,
            "464853f9b09358b3ed95e5ac7fbf63888e6458af8ec8996ca485c1d7d0581647"
        )
        XCTAssertTrue(
            plan.parentAdapterMustRemainUnmodified
        )
        XCTAssertTrue(
            plan.fixedCapEOSGenerationContractBound
        )
        XCTAssertFalse(
            plan.generationBehaviorCompatibilityComplete
        )
        XCTAssertFalse(
            plan.physicalGenerationShardsObserved
        )
        XCTAssertFalse(plan.independentRegradeExecuted)
        XCTAssertFalse(
            plan.phaseThreeCompatibilityComplete
        )
        XCTAssertFalse(plan.modelExecutionAuthorized)
        XCTAssertFalse(
            plan.functionalTrainingAuthorized
        )
        XCTAssertFalse(plan.quantizationAuthorized)
        XCTAssertFalse(plan.productUseAuthorized)
        XCTAssertFalse(plan.pythonExecutionAuthorized)

        let expanded:
            PrimeNativeGenerationContractOverlayPlan =
            try topLevelMutation(
                plan,
                key:
                    "generationBehaviorCompatibilityComplete",
                value: true
            )
        XCTAssertThrowsError(try expanded.validate())
    }

    func testArgumentsRejectNonCanonicalOverlappingAndAuthorityExpandingRoots()
        throws
    {
        let prime =
            "/private/tmp/prime-generation-contract-tests"
        let adapter =
            "\(prime)/artifacts/adapter"
        let output =
            "\(prime)/artifacts/output"
        let valid =
            try PrimeNativeGenerationContractArguments
            .parse([
                "probe",
                "--adapter-root",
                adapter,
                "--prime-root",
                prime,
                "--artifact-root",
                output,
            ])
        XCTAssertEqual(valid.adapterRoot.path, adapter)
        XCTAssertEqual(valid.primeRoot.path, prime)
        XCTAssertEqual(valid.artifactRoot.path, output)

        let invalidArguments: [[String]] = [
            [
                "probe",
                "--adapter-root",
                "/private/tmp/outside",
                "--prime-root",
                prime,
                "--artifact-root",
                output,
            ],
            [
                "probe",
                "--adapter-root",
                adapter,
                "--prime-root",
                prime,
                "--artifact-root",
                adapter,
            ],
            [
                "probe",
                "--adapter-root",
                adapter,
                "--prime-root",
                prime,
                "--artifact-root",
                "\(adapter)/nested",
            ],
            [
                "probe",
                "--adapter-root",
                "relative/adapter",
                "--prime-root",
                prime,
                "--artifact-root",
                output,
            ],
            [
                "probe",
                "--adapter-root",
                adapter,
                "--prime-root",
                prime,
                "--artifact-root",
                output,
                "--model",
                "forbidden",
            ],
        ]
        for arguments in invalidArguments {
            XCTAssertThrowsError(
                try PrimeNativeGenerationContractArguments
                    .parse(arguments)
            )
        }
        XCTAssertThrowsError(
            try PrimeNativeGenerationContractVerifierArguments
                .parse([
                    "verify",
                    "--artifact-root",
                    output,
                    "--model",
                    "forbidden",
                ])
        )
    }

    private func fixedCapObservation()
        throws
        -> PrimeNativeHistoricalRawGenerationObservation
    {
        try PrimeNativeHistoricalRawGenerationObservation(
            text: String(repeating: "A", count: 64),
            tokenIDs:
                Array(repeating: 321, count: 64),
            tokenLogProbabilities:
                Array(repeating: -0.5, count: 64),
            meanLogProbability: -0.5,
            terminatedByEOS: false,
            terminationReason: .fixedCap,
            utf8Valid: true,
            eosLogProbability: nil,
            rawFullVocabularyAllowedSupportGreedyTokenParity:
                true,
            disallowedFullVocabularyArgmaxCount: 0,
            maximumDisallowedTokenProbabilityMass:
                0.1,
            latencySeconds: 0.01
        )
    }

    private func invalidUTF8FixedCapObservation()
        throws
        -> PrimeNativeHistoricalRawGenerationObservation
    {
        try PrimeNativeHistoricalRawGenerationObservation(
            text: nil,
            tokenIDs:
                Array(repeating: 511, count: 64),
            tokenLogProbabilities:
                Array(repeating: -0.5, count: 64),
            meanLogProbability: -0.5,
            terminatedByEOS: false,
            terminationReason: .fixedCap,
            utf8Valid: false,
            eosLogProbability: nil,
            rawFullVocabularyAllowedSupportGreedyTokenParity:
                true,
            disallowedFullVocabularyArgmaxCount: 0,
            maximumDisallowedTokenProbabilityMass:
                0.1,
            latencySeconds: 0.01
        )
    }

    private func mutatedRawObservation(
        _ observation:
            PrimeNativeHistoricalRawGenerationObservation,
        changes: [String: Any]
    ) throws
        -> PrimeNativeHistoricalRawGenerationObservation
    {
        var object = try jsonObject(observation)
        for (key, value) in changes {
            object[key] = value
        }
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys]
        )
        return try JSONDecoder().decode(
            PrimeNativeHistoricalRawGenerationObservation
                .self,
            from: data
        )
    }

    private func topLevelMutation<Value: Codable>(
        _ value: Value,
        key: String,
        value replacement: Any
    ) throws -> Value {
        var object = try jsonObject(value)
        object[key] = replacement
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys]
        )
        return try JSONDecoder().decode(
            Value.self,
            from: data
        )
    }

    private func jsonObject<Value: Encodable>(
        _ value: Value
    ) throws -> [String: Any] {
        let data = try PrimeCanonicalJSON.encode(value)
        return try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        )
    }
}
