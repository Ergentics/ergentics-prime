import Foundation
import XCTest
@testable import PrimeCore

final class PrimeNativeResolvedContractAdapterTests:
    XCTestCase
{
    func testFrozenPlanBindsExactScopeAndRejectsEveryNonClaimExpansion()
        throws
    {
        let plan =
            PrimeNativeResolvedContractAdapterPlan.frozenV1

        try plan.validate()
        XCTAssertEqual(plan.schemaVersion, 1)
        XCTAssertEqual(
            plan.planID,
            "ergentics_prime_resolved_contract_compatibility_adapter_v1"
        )
        XCTAssertEqual(
            plan.claimScope,
            "frozen_tokenizer_corpus_evaluation_and_synthetic_regrade_envelope_compatibility_only"
        )
        XCTAssertEqual(
            plan.parentReceiptSHA256,
            "d8e8caefb9f0c340a7418befeca4966daf178894164eaaebdfae7b565928c8f4"
        )
        XCTAssertEqual(plan.parentReceiptByteCount, 27_035)
        XCTAssertEqual(
            plan.parentResolverSourceRevision,
            "7c7b0496a94fe776df2e542df7413fd4a8bcf250"
        )
        XCTAssertEqual(
            plan.parentResolverSourceIdentitySHA256,
            "51efb053b6c6ac4e338020842fab6a25715bf57076c0d62a3f8ea39c6a3ea05a"
        )
        XCTAssertEqual(
            plan.companionRevision,
            "163fc100710ece48119bc25954452d10f6a84f7f"
        )
        XCTAssertEqual(
            plan.companionTreeOID,
            "9009daa4f8a07fbd5897e00b9571cef44ec292db"
        )
        XCTAssertEqual(plan.expectedParentArtifactCount, 8)
        XCTAssertEqual(
            plan.expectedParentArtifactByteCount,
            11_969_097
        )
        XCTAssertEqual(plan.scientificAuthorityLanguage, "swift")
        XCTAssertTrue(plan.parentResolutionMustValidate)
        XCTAssertTrue(plan.parentArtifactsCopiedLosslessly)

        for key in [
            "parentResolutionMustValidate",
            "parentArtifactsCopiedLosslessly",
        ] {
            let weakened:
                PrimeNativeResolvedContractAdapterPlan =
                try canonicalMutation(
                    of: plan,
                    key: key,
                    value: false
                )
            XCTAssertThrowsError(
                try weakened.validate(),
                "required plan evidence must fail closed: \(key)"
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeNativeResolvedContractAdapterError,
                    .invalidPlan
                )
            }
        }

        let falseBoundaries = [
            "corpusRowsRegenerated",
            "fixedCapEOSGenerationContractBound",
            "physicalGenerationShardsObserved",
            "independentRegradeExecuted",
            "phaseThreeCompatibilityComplete",
            "archiveExpansionAuthorized",
            "donorExecutionAuthorized",
            "neuralKitExecutionAuthorized",
            "modelExecutionAuthorized",
            "functionalTrainingAuthorized",
            "quantizationAuthorized",
            "productUseAuthorized",
            "pythonExecutionAuthorized",
        ]
        let object = try canonicalObject(plan)
        for key in falseBoundaries {
            XCTAssertEqual(
                object[key] as? Bool,
                false,
                "frozen non-claim drifted: \(key)"
            )
            let expanded:
                PrimeNativeResolvedContractAdapterPlan =
                try canonicalMutation(
                    of: plan,
                    key: key,
                    value: true
                )
            XCTAssertThrowsError(
                try expanded.validate(),
                "authority expansion must fail: \(key)"
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeNativeResolvedContractAdapterError,
                    .invalidPlan
                )
            }
        }

        for mutation in [
            ("schemaVersion", 2 as Any),
            (
                "claimScope",
                "full_compatibility" as Any
            ),
            (
                "companionRevision",
                String(repeating: "0", count: 40)
                    as Any
            ),
            (
                "parentResolverSourceIdentitySHA256",
                String(repeating: "0", count: 64)
                    as Any
            ),
        ] {
            let drifted:
                PrimeNativeResolvedContractAdapterPlan =
                try canonicalMutation(
                    of: plan,
                    key: mutation.0,
                    value: mutation.1
                )
            XCTAssertThrowsError(
                try drifted.validate(),
                "plan structural drift must fail: \(mutation.0)"
            )
        }

        XCTAssertTrue(
            plan.authorityStatement.contains(
                "does not regenerate corpus rows"
            )
        )
        XCTAssertTrue(
            plan.authorityStatement.contains(
                "claim an independent scientific oracle"
            )
        )
        XCTAssertTrue(
            plan.authorityStatement.contains(
                "authorize product use"
            )
        )
    }

    func testValidProjectionAndEveryCompatibilityBoundaryFailClosed()
        throws
    {
        let projection = validProjection()
        try projection.validate()

        let data =
            try PrimeCanonicalJSON.encode(projection)
        let decoded = try PrimeCanonicalJSON.decode(
            PrimeNativeResolvedContractProjection.self,
            from: data
        )
        XCTAssertEqual(decoded, projection)
        try decoded.validate()

        let requiredTrueBoundaries = [
            "parentResolutionValidated",
            "tokenizerManifestCompatibilityComplete",
            "tokenizerMechanicsReplayComplete",
            "corpusManifestCompatibilityComplete",
            "evaluationRecordContractProjectionComplete",
            "promptOnlyGenerationBoundaryImplemented",
            "syntheticRegradeEnvelopeCompatibilityComplete",
        ]
        let requiredFalseBoundaries = [
            "corpusRowsRegenerated",
            "corpusSemanticRegradePerformed",
            "fixedCapEOSGenerationContractBound",
            "generationBehaviorCompatibilityComplete",
            "physicalGenerationShardsObserved",
            "independentRegradeExecuted",
            "phaseThreeCompatibilityComplete",
            "archiveExpanded",
            "donorExecuted",
            "neuralKitExecuted",
            "modelExecuted",
            "trainingPerformed",
            "quantizationPerformed",
            "productPromotionAuthorized",
            "independentScientificOracleClaimed",
        ]
        let object = try canonicalObject(projection)

        for key in requiredTrueBoundaries {
            XCTAssertEqual(
                object[key] as? Bool,
                true,
                "required compatibility evidence drifted: \(key)"
            )
            let withheld:
                PrimeNativeResolvedContractProjection =
                try canonicalMutation(
                    of: projection,
                    key: key,
                    value: false
                )
            assertInvalidProjection(
                withheld,
                boundary: key
            )
        }

        for key in requiredFalseBoundaries {
            XCTAssertEqual(
                object[key] as? Bool,
                false,
                "authority boundary drifted: \(key)"
            )
            let expanded:
                PrimeNativeResolvedContractProjection =
                try canonicalMutation(
                    of: projection,
                    key: key,
                    value: true
                )
            assertInvalidProjection(
                expanded,
                boundary: key
            )
        }

        let prerequisiteDrift:
            PrimeNativeResolvedContractProjection =
            try canonicalMutation(
                of: projection,
                key: "nextMissingPrerequisite",
                value: "phase_three_complete"
            )
        assertInvalidProjection(
            prerequisiteDrift,
            boundary: "nextMissingPrerequisite"
        )
    }

    func testArgumentsAdmitOnlyCanonicalDisjointPrimeArtifactRoots()
        throws
    {
        let temporaryRoot =
            FileManager.default.temporaryDirectory
            .resolvingSymlinksInPath()
            .standardizedFileURL
            .appendingPathComponent(
                "prime-native-adapter-arguments-\(UUID().uuidString)",
                isDirectory: true
            )
        let primeRoot =
            temporaryRoot.appendingPathComponent(
                "prime",
                isDirectory: true
            )
        let resolutionRoot =
            primeRoot.appendingPathComponent(
                "artifacts/resolution",
                isDirectory: true
            )
        let artifactRoot =
            primeRoot.appendingPathComponent(
                "artifacts/adapter",
                isDirectory: true
            )
        let nestedArtifactRoot =
            resolutionRoot.appendingPathComponent(
                "nested",
                isDirectory: true
            )
        let externalRoot =
            temporaryRoot.appendingPathComponent(
                "external",
                isDirectory: true
            )
        let unauthorizedPrimeOutput =
            primeRoot.appendingPathComponent(
                "output/adapter",
                isDirectory: true
            )
        for directory in [
            resolutionRoot,
            artifactRoot,
            nestedArtifactRoot,
            externalRoot,
            unauthorizedPrimeOutput,
        ] {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        }
        defer {
            try? FileManager.default.removeItem(
                at: temporaryRoot
            )
        }

        let parsed =
            try PrimeNativeResolvedContractArguments
            .parse([
                "adapter",
                "--artifact-root",
                artifactRoot.path,
                "--resolution-root",
                resolutionRoot.path,
                "--prime-root",
                primeRoot.path,
            ])
        XCTAssertEqual(parsed.primeRoot, primeRoot)
        XCTAssertEqual(
            parsed.resolutionRoot,
            resolutionRoot
        )
        XCTAssertEqual(parsed.artifactRoot, artifactRoot)

        let verifier =
            try PrimeNativeResolvedContractVerifierArguments
            .parse([
                "verifier",
                "--artifact-root",
                artifactRoot.path,
            ])
        XCTAssertEqual(verifier.artifactRoot, artifactRoot)

        for roots in [
            (
                resolutionRoot.path,
                resolutionRoot.path
            ),
            (
                resolutionRoot.path,
                nestedArtifactRoot.path
            ),
            (
                nestedArtifactRoot.path,
                resolutionRoot.path
            ),
            (
                resolutionRoot.path,
                externalRoot.path
            ),
            (
                resolutionRoot.path,
                unauthorizedPrimeOutput.path
            ),
        ] {
            XCTAssertThrowsError(
                try PrimeNativeResolvedContractArguments
                    .parse([
                        "adapter",
                        "--resolution-root",
                        roots.0,
                        "--prime-root",
                        primeRoot.path,
                        "--artifact-root",
                        roots.1,
                    ]),
                "root separation must fail for \(roots)"
            )
        }

        for forbiddenKnob in [
            "--companion-root",
            "--archive",
            "--report",
            "--source",
            "--executable",
            "--binary",
            "--command",
            "--python",
            "--shell",
            "--model",
            "--checkpoint",
            "--tokenizer",
            "--corpus",
            "--generation-shard",
            "--seed",
            "--target",
            "--target-length",
        ] {
            XCTAssertThrowsError(
                try PrimeNativeResolvedContractArguments
                    .parse([
                        "adapter",
                        "--resolution-root",
                        resolutionRoot.path,
                        "--prime-root",
                        primeRoot.path,
                        "--artifact-root",
                        artifactRoot.path,
                        forbiddenKnob,
                        externalRoot.path,
                    ]),
                "authority knob must be rejected: \(forbiddenKnob)"
            )
        }

        XCTAssertThrowsError(
            try PrimeNativeResolvedContractArguments
                .parse([
                    "adapter",
                    "--resolution-root",
                    resolutionRoot.path,
                    "--resolution-root",
                    resolutionRoot.path,
                    "--prime-root",
                    primeRoot.path,
                    "--artifact-root",
                    artifactRoot.path,
                ])
        )
        XCTAssertThrowsError(
            try PrimeNativeResolvedContractArguments
                .parse([
                    "adapter",
                    "--resolution-root",
                    "relative/path",
                    "--prime-root",
                    primeRoot.path,
                    "--artifact-root",
                    artifactRoot.path,
                ])
        )
        XCTAssertThrowsError(
            try PrimeNativeResolvedContractVerifierArguments
                .parse([
                    "verifier",
                    "--artifact-root",
                    artifactRoot.path,
                    "--seed",
                    "1618",
                ])
        )

        let alias =
            temporaryRoot.appendingPathComponent(
                "resolution-alias"
            )
        try FileManager.default.createSymbolicLink(
            at: alias,
            withDestinationURL: resolutionRoot
        )
        XCTAssertThrowsError(
            try PrimeNativeResolvedContractArguments
                .parse([
                    "adapter",
                    "--resolution-root",
                    alias.path,
                    "--prime-root",
                    primeRoot.path,
                    "--artifact-root",
                    artifactRoot.path,
                ])
        )
    }

    func testPromptOnlyRequestIsTargetIndependentAndStrictlyDecoded()
        throws
    {
        let decomposed = try
            PrimeNativePromptOnlyGenerationRequest(
                rowID: "holdout-0001",
                seed: 1_618,
                promptText: "Cafe\u{301}\n"
            )
        let canonical = try
            PrimeNativePromptOnlyGenerationRequest(
                rowID: "holdout-0001",
                seed: 1_618,
                promptText: "Café\n"
            )
        XCTAssertEqual(decomposed, canonical)
        XCTAssertEqual(
            decomposed.promptTokenIDs.first,
            PrimeNativeByteTokenizer
                .beginningOfSequenceTokenID
        )
        XCTAssertEqual(
            decomposed.promptGroupingKey,
            decomposed.promptTokenIDs.count - 1
        )

        let object = try canonicalObject(decomposed)
        XCTAssertEqual(
            Set(object.keys),
            [
                "row_id",
                "seed",
                "prompt_text",
                "prompt_token_ids",
                "prompt_grouping_key",
            ]
        )
        for forbiddenKey in [
            "target",
            "target_length",
            "expected_completion",
            "expected_completion_token_ids",
            "semantic_family",
            "mutation_id",
            "corpus_row_sha256",
            "evaluation_row_sha256",
            "semantic_verifier_pass",
            "abstention_decision",
        ] {
            var injected = object
            injected[forbiddenKey] = "leaked"
            XCTAssertThrowsError(
                try JSONDecoder().decode(
                    PrimeNativePromptOnlyGenerationRequest
                        .self,
                    from: try canonicalData(injected)
                ),
                "prompt-only decoder admitted \(forbiddenKey)"
            )
        }

        for mutation in [
            (
                "prompt_token_ids",
                [1, 256] as Any
            ),
            (
                "prompt_grouping_key",
                9_999 as Any
            ),
        ] {
            var drifted = object
            drifted[mutation.0] = mutation.1
            XCTAssertThrowsError(
                try JSONDecoder().decode(
                    PrimeNativePromptOnlyGenerationRequest
                        .self,
                    from: try canonicalData(drifted)
                ),
                "derived prompt field drift must fail: \(mutation.0)"
            )
        }
    }

    func testGenerationObservationAndRegradeAuthorityRemainStrictlySeparated()
        throws
    {
        let completion = "Result: 42.\n"
        let generatedTokenIDs =
            PrimeNativeByteTokenizer.encode(completion)
        let logProbabilities = Array(
            repeating: -0.25,
            count: generatedTokenIDs.count
        )
        let observation = try
            PrimeNativeGenerationObservation(
                rowID: "combination-holdout-0001",
                seed: 2_718,
                generatedTokenIDs: generatedTokenIDs,
                generatedCompletion: completion,
                tokenLogProbabilities:
                    logProbabilities,
                termination: .endOfSequence,
                eosLogProbability: -0.1,
                latencySeconds: 0.025
            )
        let authority = try
            PrimeNativeRegradeAuthority(
                rowID: observation.rowID,
                corpusRowSHA256:
                    String(repeating: "a", count: 64),
                evaluationRowSHA256:
                    String(repeating: "b", count: 64),
                split: .combinationHoldout,
                semanticFamily:
                    "arithmetic_composition",
                mutationID: nil,
                expectedCompletion: completion,
                expectedCompletionTokenIDs:
                    generatedTokenIDs
            )
        let input = try PrimeNativeRegradeInput(
            observation: observation,
            authority: authority
        )
        XCTAssertEqual(input.observation, observation)
        XCTAssertEqual(input.authority, authority)

        let observationObject =
            try canonicalObject(observation)
        XCTAssertNil(
            observationObject["expected_completion"]
        )
        XCTAssertNil(
            observationObject[
                "expected_completion_token_ids"
            ]
        )
        XCTAssertNil(
            observationObject["semantic_verifier_pass"]
        )
        XCTAssertNil(
            observationObject["abstention_decision"]
        )
        for forbiddenKey in [
            "expected_completion",
            "expected_completion_token_ids",
            "evaluation_row_sha256",
            "corpus_row_sha256",
            "semantic_verifier_pass",
            "abstention_decision",
        ] {
            var injected = observationObject
            injected[forbiddenKey] = "leaked"
            XCTAssertThrowsError(
                try JSONDecoder().decode(
                    PrimeNativeGenerationObservation.self,
                    from: try canonicalData(injected)
                ),
                "raw generation admitted regrade authority: \(forbiddenKey)"
            )
        }

        let authorityObject =
            try canonicalObject(authority)
        XCTAssertNil(
            authorityObject["generated_token_ids"]
        )
        XCTAssertNil(
            authorityObject["token_log_probabilities"]
        )
        XCTAssertNil(authorityObject["latency_seconds"])
        for forbiddenKey in [
            "generated_token_ids",
            "generated_completion",
            "token_log_probabilities",
            "eos_log_probability",
            "latency_seconds",
            "exact_match",
        ] {
            var injected = authorityObject
            injected[forbiddenKey] = "leaked"
            XCTAssertThrowsError(
                try JSONDecoder().decode(
                    PrimeNativeRegradeAuthority.self,
                    from: try canonicalData(injected)
                ),
                "regrade authority admitted model observation: \(forbiddenKey)"
            )
        }

        assertModelError(
            .generatedTokenLogProbabilityCountMismatch
        ) {
            _ = try PrimeNativeGenerationObservation(
                rowID: observation.rowID,
                seed: observation.seed,
                generatedTokenIDs: generatedTokenIDs,
                generatedCompletion: completion,
                tokenLogProbabilities: [],
                termination: .endOfSequence,
                eosLogProbability: -0.1,
                latencySeconds: 0.025
            )
        }
        assertModelError(
            .nonFiniteGenerationObservation
        ) {
            _ = try PrimeNativeGenerationObservation(
                rowID: observation.rowID,
                seed: observation.seed,
                generatedTokenIDs: generatedTokenIDs,
                generatedCompletion: completion,
                tokenLogProbabilities:
                    logProbabilities,
                termination: .endOfSequence,
                eosLogProbability: -0.1,
                latencySeconds: .nan
            )
        }
        assertModelError(.generationTerminationMismatch) {
            _ = try PrimeNativeGenerationObservation(
                rowID: observation.rowID,
                seed: observation.seed,
                generatedTokenIDs: generatedTokenIDs,
                generatedCompletion: completion,
                tokenLogProbabilities:
                    logProbabilities,
                termination: .endOfSequence,
                eosLogProbability: nil,
                latencySeconds: 0.025
            )
        }
        assertModelError(.generationTerminationMismatch) {
            _ = try PrimeNativeGenerationObservation(
                rowID: observation.rowID,
                seed: observation.seed,
                generatedTokenIDs: generatedTokenIDs,
                generatedCompletion: completion,
                tokenLogProbabilities:
                    logProbabilities,
                termination: .decisionLimit,
                eosLogProbability: -0.1,
                latencySeconds: 0.025
            )
        }
        assertModelError(.generatedCompletionMismatch) {
            _ = try PrimeNativeGenerationObservation(
                rowID: observation.rowID,
                seed: observation.seed,
                generatedTokenIDs: generatedTokenIDs,
                generatedCompletion: "Result: 24.\n",
                tokenLogProbabilities:
                    logProbabilities,
                termination: .endOfSequence,
                eosLogProbability: -0.1,
                latencySeconds: 0.025
            )
        }

        let wrongAuthority = try
            PrimeNativeRegradeAuthority(
                rowID: "different-row",
                corpusRowSHA256:
                    String(repeating: "a", count: 64),
                evaluationRowSHA256:
                    String(repeating: "b", count: 64),
                split: .combinationHoldout,
                semanticFamily:
                    "arithmetic_composition",
                mutationID: nil,
                expectedCompletion: completion,
                expectedCompletionTokenIDs:
                    generatedTokenIDs
            )
        assertModelError(.regradeRowMismatch) {
            _ = try PrimeNativeRegradeInput(
                observation: observation,
                authority: wrongAuthority
            )
        }
        assertModelError(.invalidExpectedCompletion) {
            _ = try PrimeNativeRegradeAuthority(
                rowID: observation.rowID,
                corpusRowSHA256:
                    String(repeating: "a", count: 64),
                evaluationRowSHA256:
                    String(repeating: "b", count: 64),
                split: .combinationHoldout,
                semanticFamily:
                    "arithmetic_composition",
                mutationID: nil,
                expectedCompletion: completion,
                expectedCompletionTokenIDs:
                    PrimeNativeByteTokenizer.encode(
                        "Result: 24.\n"
                    )
            )
        }
        assertModelError(
            .invalidSHA256("corpus_row_sha256")
        ) {
            _ = try PrimeNativeRegradeAuthority(
                rowID: observation.rowID,
                corpusRowSHA256:
                    String(repeating: "A", count: 64),
                evaluationRowSHA256:
                    String(repeating: "b", count: 64),
                split: .combinationHoldout,
                semanticFamily:
                    "arithmetic_composition",
                mutationID: nil,
                expectedCompletion: completion,
                expectedCompletionTokenIDs:
                    generatedTokenIDs
            )
        }

        let result = PrimeNativeRegradeResult(
            rowID: observation.rowID,
            seed: observation.seed,
            exactMatch: true,
            semanticVerifierPass: true,
            abstentionDecision: false
        )
        var resultObject = try canonicalObject(result)
        resultObject[
            "independent_scientific_oracle_claimed"
        ] = true
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                PrimeNativeRegradeResult.self,
                from: try canonicalData(resultObject)
            )
        )
    }

    private func validProjection()
        -> PrimeNativeResolvedContractProjection
    {
        let plan =
            PrimeNativeResolvedContractAdapterPlan.frozenV1
        let splitEvidence = zip(
            [
                "train",
                "refusal_train",
                "validation",
                "refusal_validation",
                "combination_holdout",
                "ood",
                "mutation",
                "abstention",
            ],
            [
                131_072,
                4_096,
                4_096,
                2_048,
                4_096,
                4_096,
                4_096,
                2_048,
            ]
        ).map {
            PrimeNativeResolvedContractSplitProjection(
                split: $0.0,
                rowCount: $0.1,
                historicalManifestDeclaredAllRowsIndependentlyVerified:
                    true
            )
        }
        return PrimeNativeResolvedContractProjection(
            schemaVersion: 1,
            artifactKind:
                "prime_native_resolved_contract_compatibility_projection",
            claimScope: plan.claimScope,
            parentReceiptSHA256:
                plan.parentReceiptSHA256,
            resolverSourceRevision:
                plan.parentResolverSourceRevision,
            companionRevision: plan.companionRevision,
            companionTreeOID: plan.companionTreeOID,
            tokenizerArtifactSHA256:
                plan.tokenizerArtifactSHA256,
            tokenizerManifestSHA256:
                plan.tokenizerManifestSHA256,
            tokenizerID:
                "ergentics_prime_nfc_utf8_byte_v1",
            tokenizerReplayProbeIDs: [
                "empty",
                "ascii",
                "nfc",
                "multilingual",
                "emoji",
                "whitespace",
                "nul",
            ],
            tokenizerReplayProbeSHA256:
                "9ce743183b0aecaf4e976d912382ebc11f5f6b07a868f76470dd5a0a6061f5bb",
            tokenizerVocabularySize: 512,
            tokenizerByteTokenBase: 256,
            tokenizerByteTokenCount: 256,
            tokenizerSpecialTokenIDs: [0, 1, 70],
            corpusArtifactSHA256:
                plan.corpusArtifactSHA256,
            corpusManifestSHA256:
                plan.corpusManifestSHA256,
            corpusID:
                "ergentics_prime_native_compositional_text_v1",
            totalUniqueRowCount: 155_648,
            totalTokenInstanceCount: 38_506_757,
            splitEvidence: splitEvidence,
            evaluationResultFields:
                PrimeNativeResolvedContractAdapter
                .requiredEvaluationResultFields,
            evaluationSplits:
                PrimeNativeResolvedContractAdapter
                .requiredEvaluationSplits,
            evaluationSeeds: [1_618, 2_718, 3_141],
            triadicWitnesses:
                PrimeNativeResolvedContractAdapter
                .requiredTriadicWitnesses,
            syntheticReceiptSHA256:
                plan.syntheticReceiptArtifactSHA256,
            syntheticClassification:
                "synthetic_first_party_contract_and_mutation_verification_only",
            syntheticGateOutcome: "GROUNDED",
            syntheticGateRecordCount: 59_497,
            syntheticGateMutationCount: 46,
            parentResolutionValidated: true,
            tokenizerManifestCompatibilityComplete:
                true,
            tokenizerMechanicsReplayComplete: true,
            corpusManifestCompatibilityComplete: true,
            evaluationRecordContractProjectionComplete:
                true,
            promptOnlyGenerationBoundaryImplemented:
                true,
            syntheticRegradeEnvelopeCompatibilityComplete:
                true,
            corpusRowsRegenerated: false,
            corpusSemanticRegradePerformed: false,
            fixedCapEOSGenerationContractBound: false,
            generationBehaviorCompatibilityComplete:
                false,
            physicalGenerationShardsObserved: false,
            independentRegradeExecuted: false,
            phaseThreeCompatibilityComplete: false,
            archiveExpanded: false,
            donorExecuted: false,
            neuralKitExecuted: false,
            modelExecuted: false,
            trainingPerformed: false,
            quantizationPerformed: false,
            productPromotionAuthorized: false,
            independentScientificOracleClaimed: false,
            nextMissingPrerequisite:
                "resolve_exact_fixed_cap_eos_generation_contract_projection"
        )
    }

    private func assertInvalidProjection(
        _ projection:
            PrimeNativeResolvedContractProjection,
        boundary: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try projection.validate(),
            "projection boundary must fail: \(boundary)",
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeResolvedContractAdapterError,
                .invalidProjection(
                    "structural contract"
                ),
                file: file,
                line: line
            )
        }
    }

    private func assertModelError(
        _ expected:
            PrimeNativeResolvedContractModelError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ operation: () throws -> Void
    ) {
        XCTAssertThrowsError(
            try operation(),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeResolvedContractModelError,
                expected,
                file: file,
                line: line
            )
        }
    }

    private func canonicalObject<Value: Encodable>(
        _ value: Value
    ) throws -> [String: Any] {
        try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: PrimeCanonicalJSON.encode(value)
            ) as? [String: Any]
        )
    }

    private func canonicalMutation<Value: Codable>(
        of value: Value,
        key: String,
        value replacement: Any
    ) throws -> Value {
        var object = try canonicalObject(value)
        XCTAssertNotNil(
            object[key],
            "mutation key is absent: \(key)"
        )
        object[key] = replacement
        return try PrimeCanonicalJSON.decode(
            Value.self,
            from: canonicalData(object)
        )
    }

    private func canonicalData(
        _ object: [String: Any]
    ) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: object,
            options: [
                .sortedKeys,
                .withoutEscapingSlashes,
            ]
        )
    }
}
