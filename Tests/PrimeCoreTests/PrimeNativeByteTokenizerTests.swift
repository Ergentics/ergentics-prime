import Foundation
import XCTest
@testable import PrimeCore

final class PrimeNativeByteTokenizerTests:
    XCTestCase
{
    func testFrozenConstantsAndByteMapping()
        throws
    {
        XCTAssertEqual(
            PrimeNativeByteTokenizer.padTokenID,
            0
        )
        XCTAssertEqual(
            PrimeNativeByteTokenizer
                .beginningOfSequenceTokenID,
            1
        )
        XCTAssertEqual(
            PrimeNativeByteTokenizer
                .endOfSequenceTokenID,
            70
        )
        XCTAssertEqual(
            PrimeNativeByteTokenizer.byteTokenRange,
            256 ... 511
        )
        XCTAssertEqual(
            PrimeNativeByteTokenizer.tokenSpaceSize,
            512
        )
        for byte in 0 ... 255 {
            let tokenID = try
                PrimeNativeByteTokenizer.tokenID(
                    forByte: byte
                )
            XCTAssertEqual(tokenID, 256 + byte)
            XCTAssertEqual(
                try PrimeNativeByteTokenizer.byte(
                    forTokenID: tokenID
                ),
                UInt8(byte)
            )
        }
        XCTAssertThrowsError(
            try PrimeNativeByteTokenizer.tokenID(
                forByte: -1
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeByteTokenizer.byte(
                forTokenID: 255
            )
        )
    }

    func testNFCWhitespaceLineEndingsAndNULReplay()
        throws
    {
        let decomposed = "Cafe\u{301}"
        let canonical = "Café"
        XCTAssertEqual(
            PrimeNativeByteTokenizer.canonicalize(
                decomposed
            ),
            canonical
        )
        XCTAssertEqual(
            PrimeNativeByteTokenizer.encode(
                decomposed
            ),
            PrimeNativeByteTokenizer.encode(
                canonical
            )
        )

        let source =
            " \tline one\r\nline two\n before\u{0000}after "
        let primary =
            PrimeNativeByteTokenizer.encode(source)
        let independent =
            try PrimeNativeByteTokenizer
            .encodeWithFoundationData(source)
        XCTAssertEqual(primary, independent)
        XCTAssertEqual(
            try PrimeNativeByteTokenizer.decode(
                primary
            ),
            source
        )
        XCTAssertEqual(
            try PrimeNativeByteTokenizer
                .decodeWithFoundationData(
                    independent
                ),
            source
        )
    }

    func testSequenceBoundaryAndInvalidUTF8FailClosed()
        throws
    {
        let sequence =
            PrimeNativeByteTokenizer.encodeSequence(
                "Prime"
            )
        XCTAssertEqual(sequence.first, 1)
        XCTAssertEqual(sequence.last, 70)
        XCTAssertEqual(
            try PrimeNativeByteTokenizer
                .decodeSequence(sequence),
            "Prime"
        )
        XCTAssertThrowsError(
            try PrimeNativeByteTokenizer
                .decodeSequence(
                    Array(sequence.dropFirst())
                )
        )
        XCTAssertThrowsError(
            try PrimeNativeByteTokenizer
                .decodeSequence(
                    [1, 70, 70]
                )
        )

        let invalidUTF8 = try [0xff].map {
            try PrimeNativeByteTokenizer.tokenID(
                forByte: $0
            )
        }
        XCTAssertThrowsError(
            try PrimeNativeByteTokenizer.decode(
                invalidUTF8
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeNativeByteTokenizer
                    .TokenizerError,
                .invalidUTF8
            )
        }
    }

    func testBigEndianUInt32TokenHashMatchesFrozenProbe()
        throws
    {
        let tokens =
            PrimeNativeByteTokenizer.encode(
                "Prime evidence: retain exact semantics."
            )
        XCTAssertEqual(
            try PrimeNativeByteTokenizer
                .tokenIDsSHA256(tokens),
            "c66bb8009cb73534b4c9e1a133b047b5f46a170fe4363658770ad280d3ef1069"
        )
        XCTAssertThrowsError(
            try PrimeNativeByteTokenizer
                .tokenIDsSHA256([512])
        )
    }

    func testManifestMatchesFrozenResolvedContract()
        throws
    {
        let manifest =
            try PrimeNativeByteTokenizer.manifest()
        try PrimeNativeByteTokenizer.verify(
            manifest
        )
        XCTAssertEqual(
            manifest.manifestSHA256,
            "f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7"
        )
        XCTAssertEqual(
            manifest.replayProbeSHA256,
            "9ce743183b0aecaf4e976d912382ebc11f5f6b07a868f76470dd5a0a6061f5bb"
        )
        XCTAssertEqual(
            manifest.replayProbes.map(\.id),
            [
                "empty",
                "ascii",
                "nfc",
                "multilingual",
                "emoji",
                "whitespace",
                "nul",
            ]
        )
        XCTAssertTrue(
            manifest.replayProbes.allSatisfy(
                \.independentPathsAgree
            )
        )

        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with:
                    PrimeCanonicalJSON.encode(
                        manifest
                    )
            ) as? [String: Any]
        )
        object["byte_token_base"] = 255
        let changed = try JSONDecoder().decode(
            PrimeNativeByteTokenizer.Manifest.self,
            from: JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeByteTokenizer.verify(
                changed
            )
        )
    }

    func testPromptOnlyRequestCannotEncodeTargetMaterial()
        throws
    {
        let request = try
            PrimeNativePromptOnlyGenerationRequest(
                rowID: "row-1",
                seed: 1_618,
                promptText: "Cafe\u{301}"
            )
        XCTAssertEqual(request.promptText, "Café")
        XCTAssertEqual(
            request.promptTokenIDs.first,
            PrimeNativeByteTokenizer
                .beginningOfSequenceTokenID
        )
        XCTAssertEqual(
            request.promptGroupingKey,
            PrimeNativeByteTokenizer
                .encode("Café").count
        )

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with:
                    PrimeCanonicalJSON.encode(
                        request
                    )
            ) as? [String: Any]
        )
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
        for forbidden in [
            "target",
            "expected_completion",
            "expected_completion_token_ids",
            "semantic_family",
            "mutation_id",
            "semantic_verifier",
        ] {
            XCTAssertNil(object[forbidden])
        }

        var targetInjected = object
        targetInjected["target"] = "Café"
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                PrimeNativePromptOnlyGenerationRequest
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: targetInjected,
                    options: [.sortedKeys]
                )
            )
        )

        var regrouped = object
        regrouped["prompt_grouping_key"] = 99
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                PrimeNativePromptOnlyGenerationRequest
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: regrouped,
                    options: [.sortedKeys]
                )
            )
        )
    }

    func testGenerationObservationAndPostGenerationRegradeBoundary()
        throws
    {
        let generated =
            PrimeNativeByteTokenizer.encode("42\n")
        let observation = try
            PrimeNativeGenerationObservation(
                rowID: "row-42",
                seed: 2_718,
                generatedTokenIDs: generated,
                generatedCompletion: "42\n",
                tokenLogProbabilities:
                    Array(
                        repeating: -0.25,
                        count: generated.count
                    ),
                termination: .endOfSequence,
                eosLogProbability: -0.1,
                latencySeconds: 0.02
            )
        let authority = try
            PrimeNativeRegradeAuthority(
                rowID: "row-42",
                corpusRowSHA256:
                    String(repeating: "a", count: 64),
                evaluationRowSHA256:
                    String(repeating: "b", count: 64),
                split: .combinationHoldout,
                semanticFamily:
                    "arithmetic_composition",
                mutationID: nil,
                expectedCompletion: "42\n",
                expectedCompletionTokenIDs:
                    generated
            )
        XCTAssertNoThrow(
            try PrimeNativeRegradeInput(
                observation: observation,
                authority: authority
            )
        )

        let wrongAuthority = try
            PrimeNativeRegradeAuthority(
                rowID: "other-row",
                corpusRowSHA256:
                    String(repeating: "a", count: 64),
                evaluationRowSHA256:
                    String(repeating: "b", count: 64),
                split: .combinationHoldout,
                semanticFamily:
                    "arithmetic_composition",
                mutationID: nil,
                expectedCompletion: "42\n",
                expectedCompletionTokenIDs:
                    generated
            )
        XCTAssertThrowsError(
            try PrimeNativeRegradeInput(
                observation: observation,
                authority: wrongAuthority
            )
        )

        XCTAssertThrowsError(
            try PrimeNativeGenerationObservation(
                rowID: "row-42",
                seed: 2_718,
                generatedTokenIDs: generated,
                generatedCompletion: "42\n",
                tokenLogProbabilities: [],
                termination: .endOfSequence,
                eosLogProbability: -0.1,
                latencySeconds: 0.02
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeGenerationObservation(
                rowID: "row-42",
                seed: 2_718,
                generatedTokenIDs: generated,
                generatedCompletion: "24\n",
                tokenLogProbabilities:
                    Array(
                        repeating: -0.25,
                        count: generated.count
                    ),
                termination: .decisionLimit,
                eosLogProbability: -0.1,
                latencySeconds: 0.02
            )
        )
        XCTAssertThrowsError(
            try PrimeNativeGenerationObservation(
                rowID: "row-42",
                seed: 2_718,
                generatedTokenIDs: generated,
                generatedCompletion: "42\n",
                tokenLogProbabilities:
                    Array(
                        repeating: 0.01,
                        count: generated.count
                    ),
                termination: .endOfSequence,
                eosLogProbability: -0.1,
                latencySeconds: 0.02
            )
        )

        let decomposedBytes =
            Array("e\u{301}".utf8)
        let decomposedTokenIDs =
            decomposedBytes.map {
                PrimeNativeByteTokenizer
                    .byteTokenBase + Int($0)
            }
        XCTAssertThrowsError(
            try PrimeNativeGenerationObservation(
                rowID: "row-nfc",
                seed: 2_718,
                generatedTokenIDs:
                    decomposedTokenIDs,
                generatedCompletion: "é",
                tokenLogProbabilities:
                    Array(
                        repeating: -0.25,
                        count:
                            decomposedTokenIDs.count
                    ),
                termination: .endOfSequence,
                eosLogProbability: -0.1,
                latencySeconds: 0.02
            )
        )

        var observationObject = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with:
                    PrimeCanonicalJSON.encode(
                        observation
                    )
            ) as? [String: Any]
        )
        observationObject[
            "token_log_probabilities"
        ] = []
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                PrimeNativeGenerationObservation.self,
                from: JSONSerialization.data(
                    withJSONObject: observationObject,
                    options: [.sortedKeys]
                )
            )
        )

        let boundedResult = PrimeNativeRegradeResult(
            rowID: "row-42",
            seed: 2_718,
            exactMatch: true,
            semanticVerifierPass: true,
            abstentionDecision: false
        )
        var resultObject = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with:
                    PrimeCanonicalJSON.encode(
                        boundedResult
                    )
            ) as? [String: Any]
        )
        resultObject[
            "independent_scientific_oracle_claimed"
        ] = true
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                PrimeNativeRegradeResult.self,
                from: JSONSerialization.data(
                    withJSONObject: resultObject,
                    options: [.sortedKeys]
                )
            )
        )
    }

    func testBoundedEvaluationAndSyntheticEnvelopes()
        throws
    {
        try PrimeNativeEvaluationContract
            .frozenV1.validateFrozenV1()
        XCTAssertEqual(
            PrimeNativeEvaluationContract
                .frozenV1.multiSeedConsensusSeeds,
            [1_618, 2_718, 3_141]
        )
        XCTAssertEqual(
            PrimeNativeEvaluationContract
                .frozenV1
                .verifyAbstainMinimumIndependentWitnesses,
            3
        )

        let synthetic =
            PrimeNativeSyntheticRegradeEnvelope
            .frozenV1
        try synthetic.validateFrozenV1()
        XCTAssertEqual(
            synthetic.gate.outcome,
            "GROUNDED"
        )
        XCTAssertFalse(
            synthetic.claimScope
                .schema4ProfileExecutionPerformed
        )
        XCTAssertFalse(
            synthetic.claimScope
                .functionalLanguageCapabilityClaimed
        )
        XCTAssertFalse(
            synthetic.claimScope
                .productPromotionAuthorized
        )
        XCTAssertFalse(
            PrimeNativeRegradeResult(
                rowID: "row-1",
                seed: 3_141,
                exactMatch: true,
                semanticVerifierPass: true,
                abstentionDecision: false
            ).independentScientificOracleClaimed
        )
    }
}
