import CryptoKit
import Foundation
import PrimeCore
import PrimeNativeCorpusReplayMechanics
import PrimeNativeNeuralGateCorrectedFixtureAuthority
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateCorrectedEvaluationMechanics
import PrimeNativeNeuralGatePromptSolver
import XCTest

final class PrimeNativeNeuralGatePromptSolverTests:
    XCTestCase
{
    private typealias Corpus =
        ErgenticsPrimeNativeTextCorpus
    private typealias Policy =
        PrimeNativeNeuralGateCorrectedExecutionPolicy
    private typealias Input =
        PrimeNativeNeuralGatePromptOnlyExecutionInput
    private typealias Context =
        PrimeNativeNeuralGateCorrectedReplicateContext
    private typealias Solver =
        PrimeNativeNeuralGatePromptOnlyReplicateSolver
    private typealias SyntheticLogitPolicy =
        PrimeNativeNeuralGatePromptSolverSyntheticLogitPolicy
    private typealias Execution =
        PrimeNativeNeuralGateRawExecution

    private struct SelectedFixtureRow:
        Sendable
    {
        let source: Corpus.Row
        let input: Input
    }

    private enum HarnessError:
        Error,
        LocalizedError
    {
        case invariant(String)

        var errorDescription: String? {
            switch self {
            case .invariant(let detail):
                detail
            }
        }
    }

    /// The trap-bearing source fixture is generated exactly once for this
    /// test process. Completion and correlation material remain confined to
    /// this test-side value and are never carried by `Input`.
    private static let selectedFixtureRows =
        Result<[SelectedFixtureRow], Error> {
            let splits: [Corpus.Split] = [
                .validation,
                .combinationHoldout,
                .ood,
                .mutation,
                .abstention,
            ]
            let expectedCounts: [Corpus.Split: Int] = [
                .validation: 4_096,
                .combinationHoldout: 4_096,
                .ood: 4_096,
                .mutation: 4_096,
                .abstention: 2_048,
            ]
            var rows: [Corpus.Row] = []
            for split in splits {
                let splitRows = Corpus.rows(
                    for: split
                )
                guard let expectedCount =
                        expectedCounts[split],
                      splitRows.count
                        == expectedCount
                else {
                    throw HarnessError.invariant(
                        "fixture split count drift: "
                            + "\(split.rawValue)="
                            + "\(splitRows.count)"
                    )
                }
                rows.append(contentsOf: splitRows)
            }
            rows.sort {
                Data($0.rowID.utf8)
                    .lexicographicallyPrecedes(
                        Data($1.rowID.utf8)
                    )
            }
            guard rows.count
                    == PrimeNativeNeuralGateCorrectedFixtureObservation
                    .exactRowCount,
                  Set(rows.map(\.rowID)).count
                    == rows.count,
                  rows.first?.rowID
                    == PrimeNativeNeuralGateCorrectedFixtureObservation
                    .frozenFirstRowID,
                  rows.last?.rowID
                    == PrimeNativeNeuralGateCorrectedFixtureObservation
                    .frozenLastRowID
            else {
                throw HarnessError.invariant(
                    "selected fixture identity drift"
                )
            }
            let selected = try rows.map {
                SelectedFixtureRow(
                    source: $0,
                    input: try Input.derive(
                        promptText: $0.promptText
                    )
                )
            }
            guard Set(
                selected.map {
                    $0.input.bindingSHA256
                }
            ).count == selected.count
            else {
                throw HarnessError.invariant(
                    "selected fixture prompt identity drift"
                )
            }
            return selected
        }

    private static let
        exactSyntheticLogitDigestBySelectedTokenID:
        [Int: String] =
        Dictionary(
            uniqueKeysWithValues:
                Policy.orderedCompletionSupport.map {
                    tokenID in
                    (
                        tokenID,
                        SHA256.hash(
                            data:
                                canonicalSyntheticLogitData(
                                    selectedTokenID:
                                        tokenID
                                )
                        ).map {
                            String(
                                format: "%02x",
                                $0
                            )
                        }.joined()
                    )
                }
        )

    func testEverySelectedRowIsExactAcrossReplicateTriadAndSeedKeyedPermutation()
        throws
    {
        let rows =
            try Self.selectedFixtureRows.get()
        try require(
            rows.count == 18_432,
            "exhaustive fixture count is not 18,432"
        )
        var referenceDecisionManifestByInput:
            [String: [String]] = [:]
        var traceSHA256ValuesByInput:
            [String: Set<String>] = [:]

        for (
            seedIndex,
            seed
        ) in Policy.admittedEvaluationSeeds
            .enumerated()
        {
            let context = try Context(
                evaluationSeed: seed
            )
            let solver = try Solver(
                replicateContext: context
            )
            var canonicalTraceByInput:
                [String: String] = [:]

            for row in rows {
                let execution = try solver.solve(
                    row.input
                )
                try validate(
                    execution,
                    for: row,
                    context: context
                )
                let inputIdentity =
                    row.input.bindingSHA256
                canonicalTraceByInput[
                    inputIdentity
                ] = execution.traceSHA256
                let decisionManifest =
                    execution.decisions.map(
                        \.fullVocabularyLogitsSHA256
                    )
                if seedIndex == 0 {
                    referenceDecisionManifestByInput[
                        inputIdentity
                    ] = decisionManifest
                } else {
                    try require(
                        referenceDecisionManifestByInput[
                            inputIdentity
                        ] == decisionManifest,
                        "replicate seed changed "
                            + "decision-logit manifest "
                            + "for row "
                            + row.source.rowID
                    )
                }
                traceSHA256ValuesByInput[
                    inputIdentity,
                    default: []
                ].insert(execution.traceSHA256)
            }
            try require(
                canonicalTraceByInput.count
                    == rows.count,
                "canonical trace manifest is incomplete "
                    + "for seed \(seed)"
            )

            let permuted =
                deterministicPermutation(
                    rows,
                    seed: seed
                )
            try require(
                permuted.count == rows.count,
                "permutation count drift for seed \(seed)"
            )
            try require(
                permuted.map {
                    $0.input.bindingSHA256
                } != rows.map {
                    $0.input.bindingSHA256
                },
                "seed-keyed permutation retained "
                    + "canonical order for seed \(seed)"
            )
            try require(
                Set(
                    permuted.map {
                        $0.input.bindingSHA256
                    }
                )
                    == Set(
                        rows.map {
                            $0.input.bindingSHA256
                        }
                    ),
                "seed-keyed permutation changed "
                    + "fixture membership for seed \(seed)"
            )

            for row in permuted {
                let replay = try solver.solve(
                    row.input
                )
                let canonicalTrace = try requireValue(
                    canonicalTraceByInput[
                        row.input.bindingSHA256
                    ],
                    "missing canonical trace for "
                        + row.source.rowID
                )
                try require(
                    replay.traceSHA256
                        == canonicalTrace,
                    "row order changed raw execution "
                        + "for seed \(seed), row "
                        + row.source.rowID
                )
                try require(
                    replay.outputUTF8
                        == Data(
                            row.source
                                .expectedCompletion
                                .utf8
                        ),
                    "permuted replay output drift "
                        + "for seed \(seed), row "
                        + row.source.rowID
                )
                try require(
                    replay.decisions.map(
                        \.fullVocabularyLogitsSHA256
                    )
                        == referenceDecisionManifestByInput[
                            row.input.bindingSHA256
                        ],
                    "permuted replay changed "
                        + "decision-logit manifest "
                        + "for seed \(seed), row "
                        + row.source.rowID
                )
            }
        }

        try require(
            Policy.admittedEvaluationSeeds
                == [1_618, 2_718, 3_141],
            "replicate triad drift"
        )
        try require(
            referenceDecisionManifestByInput.count
                == rows.count,
            "per-input decision-logit manifest "
                + "is incomplete"
        )
        try require(
            traceSHA256ValuesByInput.count
                == rows.count
                && traceSHA256ValuesByInput
                    .values
                    .allSatisfy {
                        $0.count
                            == Policy
                            .admittedEvaluationSeeds
                            .count
                    },
            "replicate seed was not bound into "
                + "every per-input raw trace identity"
        )
    }

    func testSyntheticLogitPolicyIsExactStructuralAndNonEvidentiary()
        throws
    {
        XCTAssertEqual(
            SyntheticLogitPolicy.structuralEncodingID,
            "prime_prompt_solver_structural_non_probabilistic_full_512_selected_plus_one_unselected_minus_one_v1"
        )
        XCTAssertEqual(
            SyntheticLogitPolicy
                .fullVocabularyLogitCount,
            512
        )
        XCTAssertEqual(
            SyntheticLogitPolicy
                .fullVocabularyLogitCount,
            Policy.fullVocabularyLogitCount
        )
        XCTAssertEqual(
            SyntheticLogitPolicy
                .selectedLogitBitPattern,
            0x3f80_0000
        )
        XCTAssertEqual(
            SyntheticLogitPolicy
                .unselectedLogitBitPattern,
            0xbf80_0000
        )
        XCTAssertEqual(
            SyntheticLogitPolicy
                .selectedLogit.bitPattern,
            SyntheticLogitPolicy
                .selectedLogitBitPattern
        )
        XCTAssertEqual(
            SyntheticLogitPolicy.selectedLogit,
            Float(1)
        )
        XCTAssertEqual(
            SyntheticLogitPolicy
                .unselectedLogit.bitPattern,
            SyntheticLogitPolicy
                .unselectedLogitBitPattern
        )
        XCTAssertEqual(
            SyntheticLogitPolicy.unselectedLogit,
            Float(-1)
        )
        XCTAssertEqual(
            SyntheticLogitPolicy
                .fullVocabularyLogitDigestSerializationID,
            "primefvl1_then_512_float32_bit_patterns_uint32_big_endian_in_token_id_order_v1"
        )
        XCTAssertFalse(
            SyntheticLogitPolicy
                .probabilityEvidenceClaimed
        )
        XCTAssertFalse(
            SyntheticLogitPolicy
                .calibrationEvidenceClaimed
        )
        XCTAssertFalse(
            SyntheticLogitPolicy
                .lossEvidenceClaimed
        )
        XCTAssertFalse(
            SyntheticLogitPolicy
                .sourcePinnedFloat32LogSoftmaxEvidenceClaimed
        )
        XCTAssertFalse(
            SyntheticLogitPolicy
                .modelEvidenceClaimed
        )

        let input = try Input.derive(
            promptText: [
                "Initially, amber has value 1.",
                "First, add 1 to amber.",
                "What is the final value of amber?",
                "Answer:",
                "",
            ].joined(separator: "\n")
        )
        let solver = try Solver(
            replicateContext: Context(
                evaluationSeed: 1_618
            )
        )
        let execution = try solver.solve(input)
        try validateDecisionStructure(
            execution,
            expectedTokenIDs:
                completionTokenIDs(
                    for: "Result: 2.\n"
                ),
            detail: "focused structural policy"
        )
    }

    func testPublicProvenanceExactlyMatchesFrozenSourceDerivation()
        throws
    {
        typealias Provenance =
            PrimeNativeNeuralGatePromptSolverProvenance
        let sourceDerivation = try requireValue(
            PrimeNativeNeuralGateFixtureReplayPlan
                .frozenV4
                .correctedExecutionAdmission
                .promptOnlySolverSourceDerivation,
            "frozen plan omits prompt-solver provenance"
        )
        XCTAssertNoThrow(
            try sourceDerivation.validate()
        )
        XCTAssertEqual(
            Provenance.rightsHolder,
            sourceDerivation.rightsHolder
        )
        XCTAssertEqual(
            Provenance.licenseIdentifier,
            sourceDerivation.licenseIdentifier
        )
        XCTAssertEqual(
            Provenance.sourceRemoteURL,
            sourceDerivation.sourceRemoteURL
        )
        XCTAssertEqual(
            Provenance.sourceRevision,
            sourceDerivation.sourceRevision
        )
        XCTAssertEqual(
            Provenance.sourceTreeOID,
            sourceDerivation.sourceTreeOID
        )
        XCTAssertEqual(
            Provenance.donorRelativePath,
            sourceDerivation.donorRelativePath
        )
        XCTAssertEqual(
            Provenance.donorGitBlobOID,
            sourceDerivation.donorGitBlobOID
        )
        XCTAssertEqual(
            Provenance.donorByteCount,
            sourceDerivation.donorByteCount
        )
        XCTAssertEqual(
            Provenance.donorSHA256,
            sourceDerivation.donorSHA256
        )
        XCTAssertEqual(
            Provenance.implementationLanguage,
            "Swift"
        )
        XCTAssertFalse(
            Provenance.adaptationByteExact
        )
        XCTAssertEqual(
            Provenance.adaptationByteExact,
            sourceDerivation.adaptationByteExact
        )
        XCTAssertFalse(
            Provenance.trapBearingDependencyPermitted
        )
        XCTAssertEqual(
            Provenance
                .trapBearingDependencyPermitted,
            sourceDerivation
                .trapBearingDependencyPermitted
        )
        XCTAssertFalse(
            Provenance
                .independentScientificOracleClaimed
        )
        XCTAssertEqual(
            Provenance
                .independentScientificOracleClaimed,
            sourceDerivation
                .independentScientificOracleClaimed
        )
        XCTAssertFalse(
            Provenance.modelExecutionClaimed
        )
        XCTAssertFalse(
            Provenance.productAuthorityClaimed
        )
        XCTAssertEqual(
            Provenance.adaptationDisposition,
            "trap_free_swift_foundation_semantic_adaptation_not_byte_exact_v1"
        )
        XCTAssertEqual(
            Provenance.claimScope,
            "deterministic_synthetic_prompt_solver_no_model_execution_independent_scientific_oracle_or_product_claim_v1"
        )
    }

    func testOuterCorrelationAndCompletionSubstitutionCannotChangeRawExecution()
        throws
    {
        let rows =
            try Self.selectedFixtureRows.get()
        let row = try requireValue(
            rows.first {
                $0.source.expectedCompletion
                    != "ABSTAIN\n"
            },
            "no non-abstention row found"
        )
        let context = try Context(
            evaluationSeed: 2_718
        )
        let solver = try Solver(
            replicateContext: context
        )
        XCTAssertEqual(
            Mirror(reflecting: row.input)
                .children
                .compactMap(\.label),
            [
                "promptTokenIDs",
            ]
        )
        XCTAssertEqual(
            Mirror(reflecting: solver)
                .children
                .compactMap(\.label),
            [
                "replicateContext",
                "grammar",
            ]
        )
        let baseline = try solver.solve(
            row.input
        )
        try validate(
            baseline,
            for: row,
            context: context
        )

        let correlationIDs = [
            row.source.rowID,
            "split-\(row.source.split)",
            "family-\(row.source.semanticFamily)",
        ]
        for correlationID in correlationIDs {
            let envelope =
                try PrimeNativeNeuralGateCorrectedCorrelationEnvelope(
                    correlationID: correlationID,
                    executionInput: row.input
                )
            let replay = try solver.solve(
                envelope.executionInput
            )
            try require(
                replay == baseline,
                "outer correlation changed raw execution: "
                    + correlationID
            )
        }

        let original =
            row.source.expectedCompletion
        let sameLength = String(
            repeating: "X",
            count: Data(original.utf8).count
        )
        let differentLength =
            original == "Y\n" ? "ZZ\n" : "Y\n"
        try require(
            Data(sameLength.utf8).count
                == Data(original.utf8).count,
            "same-length substitution harness drift"
        )
        try require(
            Data(differentLength.utf8).count
                != Data(original.utf8).count,
            "different-length substitution harness drift"
        )

        let materials = try [
            original,
            sameLength,
            differentLength,
        ].map {
            try PrimeNativeNeuralGatePostExecutionRegradeMaterial(
                expectedCompletion: $0
            )
        }
        var regrades:
            [PrimeNativeNeuralGatePredictionRegradeObservation] =
            []
        for material in materials {
            let replay = try solver.solve(
                row.input
            )
            try require(
                replay == baseline,
                "completion substitution changed "
                    + "raw execution"
            )
            regrades.append(
                PrimeNativeNeuralGatePredictionRegradeObservation
                    .recompute(
                        execution: replay,
                        material: material
                    )
            )
        }
        try require(
            regrades.map(\.rawExecutionSHA256)
                == Array(
                    repeating: baseline.traceSHA256,
                    count: 3
                ),
            "completion substitution changed "
                + "the raw execution identity"
        )
        try require(
            regrades.map(\.exactMatch)
                == [true, false, false],
            "completion substitution did not remain "
                + "post-execution-only"
        )
    }

    func testMalformedOverflowAndComplexityInputsFailClosedToAbstention()
        throws
    {
        let malformed =
            """
            Initially, amber has value 1.
            What is the final value of amber?
            What is the final value of amber?
            Answer:

            """
        let overflow =
            """
            Initially, amber has value \(Int.max).
            First, add 1 to amber.
            What is the final value of amber?
            Answer:

            """
        let complexityActions =
            (0 ..< 96).map {
                $0 == 0
                    ? "First, add 1 to amber."
                    : "Then, add 1 to amber."
            }
        let complexity =
            (
                [
                    "Initially, amber has value 0.",
                ]
                    + complexityActions
                    + [
                        "What is the final value of amber?",
                        "Answer:",
                        "",
                    ]
            ).joined(separator: "\n")
        let validScalar = [
            "Initially, amber has value 1.",
            "First, add 1 to amber.",
            "What is the final value of amber?",
            "Answer:",
            "",
        ].joined(separator: "\n")
        let junkRelationHeader = [
            "Use these relations. Junk",
            "First, birch is 2 steps right of amber.",
            "What is the signed distance from amber to birch?",
            "Answer:",
            "",
        ].joined(separator: "\n")
        let junkUnanchoredTransferHeader = [
            "Junk: Initially, amber holds 3; birch holds 4; cobalt holds 5.",
            "First, move 1 from amber to birch.",
            "What does amber finally hold?",
            "Answer:",
            "",
        ].joined(separator: "\n")
        let arbitraryActionLead = [
            "Initially, amber has value 1.",
            "Arbitrary, add 1 to amber.",
            "What is the final value of amber?",
            "Answer:",
            "",
        ].joined(separator: "\n")
        let mixedActionLeads = [
            "Initially, amber has value 1.",
            "First, add 1 to amber.",
            "Continue, add 1 to amber.",
            "What is the final value of amber?",
            "Answer:",
            "",
        ].joined(separator: "\n")
        let surfaceMismatchedScalarQuestion = [
            "Initially, amber has value 1.",
            "First, add 1 to amber.",
            "Return the final reading of amber.",
            "Answer:",
            "",
        ].joined(separator: "\n")
        let surfaceMismatchedTransferQuestion = [
            "Initially, amber holds 3; birch holds 4; cobalt holds 5.",
            "First, move 1 from amber to birch.",
            "Return the final holding of amber.",
            "Answer:",
            "",
        ].joined(separator: "\n")
        let missingTerminalLF =
            String(validScalar.dropLast())
        let interiorBlank = [
            "Initially, amber has value 1.",
            "First, add 1 to amber.",
            "",
            "What is the final value of amber?",
            "Answer:",
            "",
        ].joined(separator: "\n")
        let extraTerminalLF =
            validScalar + "\n"
        let crlf =
            validScalar.replacingOccurrences(
                of: "\n",
                with: "\r\n"
            )
        try require(
            Data(complexity.utf8).count
                <= Policy.maximumPromptByteCount,
            "complexity falsifier exceeds the "
                + "prompt transport cap"
        )

        let cases = [
            ("malformed", malformed),
            ("arithmetic_overflow", overflow),
            ("complexity", complexity),
            (
                "junk_relation_header",
                junkRelationHeader
            ),
            (
                "junk_unanchored_transfer_header",
                junkUnanchoredTransferHeader
            ),
            (
                "arbitrary_action_lead",
                arbitraryActionLead
            ),
            (
                "mixed_action_leads",
                mixedActionLeads
            ),
            (
                "surface_mismatched_scalar_question",
                surfaceMismatchedScalarQuestion
            ),
            (
                "surface_mismatched_transfer_question",
                surfaceMismatchedTransferQuestion
            ),
            (
                "missing_terminal_lf",
                missingTerminalLF
            ),
            ("interior_blank", interiorBlank),
            (
                "extra_terminal_lf",
                extraTerminalLF
            ),
            ("crlf", crlf),
        ]
        for seed in Policy.admittedEvaluationSeeds {
            let context = try Context(
                evaluationSeed: seed
            )
            let solver = try Solver(
                replicateContext: context
            )
            for (name, prompt) in cases {
                let input = try Input.derive(
                    promptText: prompt
                )
                let execution = try solver.solve(
                    input
                )
                try require(
                    execution.replicateContext
                        == context,
                    "\(name) lost replicate context"
                )
                try require(
                    execution.input == input,
                    "\(name) changed prompt input"
                )
                try require(
                    execution.termination == .eos,
                    "\(name) did not terminate with EOS"
                )
                try require(
                    execution.outputUTF8
                        == Data("ABSTAIN\n".utf8),
                    "\(name) did not fail closed "
                        + "to ABSTAIN for seed \(seed)"
                )
                try require(
                    execution.outputText
                        == "ABSTAIN\n",
                    "\(name) emitted invalid UTF-8"
                )
                try validateDecisionStructure(
                    execution,
                    expectedTokenIDs:
                        completionTokenIDs(
                            for: "ABSTAIN\n"
                        ),
                    detail:
                        "\(name), seed \(seed)"
                )
            }
        }
    }

    func testSolverSourceAndPackageClosureExcludeHiddenExecutionAuthority()
        throws
    {
        let solverSource = try swiftSource(
            roots: [
                "PrimeNativeNeuralGatePromptSolver",
            ]
        )
        let fullClosureSource = try swiftSource(
            roots: [
                "PrimeNativeNeuralGatePromptSolver",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )
        for forbidden in [
            "Process(",
            "NSTask",
            "posix_spawn",
            "dlopen",
            " system(",
            "popen(",
            "URLSession",
            "FileHandle",
            "FileManager",
            "Data(contentsOf:",
            "String(contentsOf:",
            ".write(to:",
            "try" + "!",
            " as" + "!",
            "fatalError(",
            "precondition(",
            "preconditionFailure(",
            "assert(",
            "Python",
            "PMHNP",
            "NeuralKit",
            "MLX",
        ] {
            XCTAssertFalse(
                fullClosureSource.contains(forbidden),
                "prompt-solver closure admits "
                    + "forbidden authority: \(forbidden)"
            )
        }
        let postfixBang =
            try NSRegularExpression(
                pattern: #"[A-Za-z0-9_\]\)]!"#
            )
        XCTAssertNil(
            postfixBang.firstMatch(
                in: fullClosureSource,
                options: [],
                range: NSRange(
                    fullClosureSource.startIndex
                        ..< fullClosureSource.endIndex,
                    in: fullClosureSource
                )
            ),
            "prompt-solver closure admits "
                + "a force-unwrap trap"
        )
        for forbidden in [
            "import PrimeNativeCorpusReplayMechanics",
            "import PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "ErgenticsPrimeNativeTextCorpus.rows",
            "ErgenticsPrimeNativeTextCorpus.Row",
            "PrimeNativeByteTokenizer.encode",
            "PrimeNativeByteTokenizer.decode",
            "targetToken",
            "target_token",
            "targetCompletion",
            "target_completion",
            "PrimeNativeNeuralGateCorrectedCorrelationEnvelope",
            "PrimeNativeNeuralGatePostExecutionRegradeMaterial",
            "PrimeNativeNeuralGatePredictionRegradeObservation",
            "expectedCompletion",
            "expected_completion",
        ] {
            XCTAssertFalse(
                solverSource.contains(forbidden),
                "prompt solver admits hidden row or "
                    + "post-execution authority: \(forbidden)"
            )
        }

        let package = try String(
            contentsOf:
                repositoryRoot
                .appendingPathComponent("Package.swift"),
            encoding: .utf8
        ).filter {
            !$0.isWhitespace
        }
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGatePromptSolver",dependencies:["PrimeNativeNeuralGateCorrectedMechanics",])"#
            )
        )
        for forbiddenDependency in [
            "PrimeNativeCorpusReplayMechanics",
            "PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "PrimeCore",
        ] {
            XCTAssertFalse(
                package.contains(
                    #".target(name:"PrimeNativeNeuralGatePromptSolver",dependencies:["PrimeNativeNeuralGateCorrectedMechanics","\#(forbiddenDependency)""#
                ),
                "prompt solver added forbidden package "
                    + "dependency \(forbiddenDependency)"
            )
            XCTAssertFalse(
                package.contains(
                    #".target(name:"PrimeNativeNeuralGatePromptSolver",dependencies:["\#(forbiddenDependency)""#
                ),
                "prompt solver starts from forbidden "
                    + "package dependency "
                    + forbiddenDependency
            )
        }
    }

    private func validate(
        _ execution: Execution,
        for row: SelectedFixtureRow,
        context: Context
    ) throws {
        let detail =
            "seed \(context.evaluationSeed), row "
            + row.source.rowID
        try require(
            execution.replicateContext == context,
            "replicate context drift: \(detail)"
        )
        try require(
            execution.input == row.input,
            "prompt input drift: \(detail)"
        )
        try require(
            execution.termination == .eos,
            "non-EOS completion: \(detail)"
        )
        try require(
            execution.outputUTF8
                == Data(
                    row.source.expectedCompletion.utf8
                ),
            "exact output mismatch: \(detail)"
        )
        try require(
            execution.outputText
                == row.source.expectedCompletion,
            "UTF-8 output mismatch: \(detail)"
        )
        try validateDecisionStructure(
            execution,
            expectedTokenIDs:
                completionTokenIDs(
                    for:
                        row.source
                        .expectedCompletion
                ),
            detail: detail
        )
    }

    private func validateDecisionStructure(
        _ execution: Execution,
        expectedTokenIDs: [Int],
        detail: String
    ) throws {
        let selected =
            execution.decisions.map(\.selectedTokenID)
        try require(
            selected
                == expectedTokenIDs
                    + [Policy.endOfSequenceTokenID],
            "selected-token trace mismatch: \(detail)"
        )
        try require(
            execution.generatedTokenIDs
                == expectedTokenIDs,
            "generated-token trace mismatch: \(detail)"
        )
        try require(
            execution.decisionsExecuted
                == expectedTokenIDs.count + 1,
            "decision count mismatch: \(detail)"
        )
        try require(
            execution.decisions.map(\.ordinal)
                == execution.decisions.indices.map {
                    $0 + 1
                },
            "decision ordinal mismatch: \(detail)"
        )
        try require(
            execution.decisions.count
                == selected.count,
            "selected-decision count drift: \(detail)"
        )
        for (
            decision,
            selectedTokenID
        ) in zip(execution.decisions, selected) {
            try require(
                decision.fullVocabularyLogits.count
                    == 512,
                "partial structural logits: \(detail)"
            )
            for (
                tokenID,
                logit
            ) in decision.fullVocabularyLogits
                .enumerated()
            {
                let expectedBitPattern =
                    tokenID == selectedTokenID
                    ? SyntheticLogitPolicy
                        .selectedLogitBitPattern
                    : SyntheticLogitPolicy
                        .unselectedLogitBitPattern
                try require(
                    logit.isFinite
                        && logit.bitPattern
                            == expectedBitPattern,
                    "synthetic logit structure drift "
                        + "at token \(tokenID): "
                        + detail
                )
            }
            let expectedDigest = try requireValue(
                Self
                    .exactSyntheticLogitDigestBySelectedTokenID[
                        selectedTokenID
                    ],
                "missing exact PRIMEFVL1 digest "
                    + "for token \(selectedTokenID)"
            )
            try require(
                decision.fullVocabularyLogitsSHA256
                    == expectedDigest,
                "PRIMEFVL1 logit digest drift: "
                    + detail
            )
        }
        try require(
            execution
                .rawFullVocabularyAllowedSupportGreedyTokenParity,
            "allowed/full-vocabulary argmax drift: "
                + detail
        )
        try require(
            execution.disallowedFullVocabularyArgmaxCount
                == 0,
            "disallowed full-vocabulary argmax: "
                + detail
        )
    }

    private func deterministicPermutation(
        _ rows: [SelectedFixtureRow],
        seed: Int
    ) -> [SelectedFixtureRow] {
        rows.map {
            (
                row: $0,
                key: permutationKey(
                    seed: seed,
                    input: $0.input
                )
            )
        }.sorted {
            if $0.key == $1.key {
                return $0.row.input.bindingSHA256
                    < $1.row.input.bindingSHA256
            }
            return $0.key.lexicographicallyPrecedes(
                $1.key
            )
        }.map(\.row)
    }

    private func permutationKey(
        seed: Int,
        input: Input
    ) -> Data {
        var data = Data("PRIMEPSP1".utf8)
        var seedBytes =
            UInt64(seed).bigEndian
        withUnsafeBytes(of: &seedBytes) {
            data.append(contentsOf: $0)
        }
        data.append(input.canonicalBindingData())
        return Data(SHA256.hash(data: data))
    }

    private func completionTokenIDs(
        for completion: String
    ) -> [Int] {
        completion.utf8.map {
            Int($0) + Policy.byteTokenBase
        }
    }

    private static func canonicalSyntheticLogitData(
        selectedTokenID: Int
    ) -> Data {
        var data = Data("PRIMEFVL1".utf8)
        for tokenID in
            0 ..< SyntheticLogitPolicy
            .fullVocabularyLogitCount
        {
            var bitPattern =
                (
                    tokenID == selectedTokenID
                    ? SyntheticLogitPolicy
                        .selectedLogitBitPattern
                    : SyntheticLogitPolicy
                        .unselectedLogitBitPattern
                ).bigEndian
            withUnsafeBytes(of: &bitPattern) {
                data.append(contentsOf: $0)
            }
        }
        return data
    }

    private func swiftSource(
        roots: [String]
    ) throws -> String {
        var files: [URL] = []
        for name in roots {
            let root =
                repositoryRoot
                .appendingPathComponent(
                    "Sources/\(name)",
                    isDirectory: true
                )
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
                throw HarnessError.invariant(
                    "cannot enumerate \(name)"
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
        guard !files.isEmpty else {
            throw HarnessError.invariant(
                "source closure is empty"
            )
        }
        return try files.sorted {
            $0.path < $1.path
        }.map {
            try String(
                contentsOf: $0,
                encoding: .utf8
            )
        }.joined(separator: "\n")
    }

    private func require(
        _ condition: @autoclosure () -> Bool,
        _ detail: @autoclosure () -> String
    ) throws {
        guard condition() else {
            throw HarnessError.invariant(
                detail()
            )
        }
    }

    private func requireValue<T>(
        _ value: T?,
        _ detail: @autoclosure () -> String
    ) throws -> T {
        guard let value else {
            throw HarnessError.invariant(
                detail()
            )
        }
        return value
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
