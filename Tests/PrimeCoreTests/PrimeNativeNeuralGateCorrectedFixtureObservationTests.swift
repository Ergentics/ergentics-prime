import CryptoKit
import Foundation
import PrimeCore
import PrimeNativeCorpusReplay
import PrimeNativeNeuralGateContract
import XCTest
@testable import PrimeNativeNeuralGateCorrectedFixtureAuthority

final class PrimeNativeNeuralGateCorrectedFixtureObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeNeuralGateCorrectedFixtureObservation

    private static let frozenObservation =
        Result<Observation, Error> {
            try Observation.runAndValidate()
        }

    func testSourceDerivedFixtureMatchesEveryFrozenGolden()
        throws
    {
        let observation =
            try Self.frozenObservation.get()

        XCTAssertEqual(observation.exactRowCount, 18_432)
        XCTAssertEqual(
            observation.uniqueRowIDCount,
            observation.exactRowCount
        )
        XCTAssertEqual(
            observation.uniquePromptOnlyInputCount,
            observation.exactRowCount
        )
        XCTAssertEqual(
            observation.selectedSplitOrder,
            [
                "validation",
                "combination_holdout",
                "ood",
                "mutation",
                "abstention",
            ]
        )
        XCTAssertEqual(
            observation
                .selectedSplitIdentities
                .map(\.rowCount),
            [
                4_096,
                4_096,
                4_096,
                4_096,
                2_048,
            ]
        )
        XCTAssertEqual(
            observation.orderedRowIDsSHA256,
            Observation.frozenOrderedRowIDsSHA256
        )
        XCTAssertEqual(
            observation.orderedEvaluationRowsSHA256,
            Observation
                .frozenOrderedEvaluationRowsSHA256
        )
        XCTAssertEqual(
            observation
                .orderedPromptOnlyInputBindingsSHA256,
            Observation
                .frozenOrderedPromptOnlyInputBindingsSHA256
        )
        XCTAssertEqual(
            observation
                .orderedTargetTokenBindingsSHA256,
            Observation
                .frozenOrderedTargetTokenBindingsSHA256
        )
        XCTAssertEqual(
            observation
                .orderedCompleteRowBindingsSHA256,
            Observation
                .frozenOrderedCompleteRowBindingsSHA256
        )
        XCTAssertEqual(
            observation.fixtureIdentitySHA256,
            Observation.frozenFixtureIdentitySHA256
        )
        XCTAssertEqual(
            try observation.contentSHA256(),
            Observation.frozenObservationSHA256
        )
        XCTAssertNoThrow(
            try observation.validateFrozen()
        )
    }

    func testCompletionAdmissionIsCompleteAndNotExecutionAuthority()
        throws
    {
        let observation =
            try Self.frozenObservation.get()

        XCTAssertTrue(observation.allPromptsCanonicalNFC)
        XCTAssertTrue(
            observation.allCompletionsCanonicalNFC
        )
        XCTAssertTrue(
            observation
                .allCompletionsFitFixedCapWithEOS
        )
        XCTAssertEqual(
            observation.maximumPromptTokenCount,
            500
        )
        XCTAssertEqual(
            observation.maximumCompletionTokenCount,
            17
        )
        XCTAssertEqual(
            observation
                .maximumCompletionDecisionsIncludingEOS,
            18
        )
        XCTAssertTrue(
            observation.sourceDerivedFixtureIdentityBound
        )
        XCTAssertFalse(
            observation
                .independentFixtureProbeVerifierReceiptPublished
        )
        XCTAssertFalse(
            observation.receiptBytesReadDuringDerivation
        )
        XCTAssertFalse(
            observation
                .promptOnlySolverSourceDerivationBound
        )
        XCTAssertFalse(
            observation.modelExecutionPerformed
        )
        XCTAssertFalse(
            observation.stageBExecutionAuthorized
        )
        XCTAssertFalse(
            observation.terminalReceiptAuthorized
        )
    }

    func testSourceAndReceiptPinsMatchClosedPrimeAuthorities()
        throws
    {
        let observation =
            try Self.frozenObservation.get()
        let plan =
            PrimeNativeNeuralGateFixtureReplayPlan
                .frozenV3
        let tokenizer = try XCTUnwrap(
            plan.inputPins.first {
                $0.role
                    == .nativeByteTokenizerAuthority
            }
        )
        let corpus = try XCTUnwrap(
            plan.inputPins.first {
                $0.role
                    == .nativeTextCorpusAuthority
            }
        )
        let fixture = try XCTUnwrap(
            plan.inputPins.first {
                $0.role
                    == .behavioralRegressionFixture
            }
        )

        XCTAssertEqual(
            observation.companionRevision,
            plan.companionRevision
        )
        XCTAssertEqual(
            observation.companionTreeOID,
            plan.companionTreeOID
        )
        XCTAssertEqual(
            observation.tokenizerSourceGitBlobOID,
            tokenizer.gitBlobOID
        )
        XCTAssertEqual(
            observation.tokenizerSourceSHA256,
            tokenizer.sha256
        )
        XCTAssertEqual(
            observation.corpusSourceGitBlobOID,
            corpus.gitBlobOID
        )
        XCTAssertEqual(
            observation.corpusSourceSHA256,
            corpus.sha256
        )
        XCTAssertEqual(
            observation
                .historicalFixtureSourceGitBlobOID,
            fixture.gitBlobOID
        )
        XCTAssertEqual(
            observation
                .historicalFixtureSourceSHA256,
            fixture.sha256
        )
        let sourceBindings = Dictionary(
            uniqueKeysWithValues:
                observation.sourceBindings.map {
                    ($0.role, $0)
                }
        )
        let bindingCases = [
            (
                "native_byte_tokenizer_authority",
                tokenizer
            ),
            (
                "native_text_corpus_authority",
                corpus
            ),
            (
                "behavioral_regression_fixture_lineage_only",
                fixture
            ),
        ]
        for (role, pin) in bindingCases {
            let binding = try XCTUnwrap(
                sourceBindings[role]
            )
            XCTAssertEqual(
                binding.repositoryRelativePath,
                pin.repositoryRelativePath
            )
            XCTAssertEqual(binding.mode, pin.mode)
            XCTAssertEqual(
                binding.objectType,
                pin.objectType
            )
            XCTAssertEqual(
                binding.gitBlobOID,
                pin.gitBlobOID
            )
            XCTAssertEqual(
                binding.byteCount,
                pin.byteCount
            )
            XCTAssertEqual(
                binding.sha256,
                pin.sha256
            )
        }

        let receiptCases: [
            (
                path: String,
                bytes: Int,
                sha256: String
            )
        ] = [
            (
                observation.stageAReceiptRelativePath,
                observation.stageAReceiptByteCount,
                observation.stageAReceiptSHA256
            ),
            (
                observation
                    .fullCorpusReplayReceiptRelativePath,
                observation
                    .fullCorpusReplayReceiptByteCount,
                observation
                    .fullCorpusReplayReceiptSHA256
            ),
        ]
        for receipt in receiptCases {
            let data = try Data(
                contentsOf:
                    repositoryRoot
                    .appendingPathComponent(receipt.path)
            )
            XCTAssertEqual(data.count, receipt.bytes)
            XCTAssertEqual(
                sha256(data),
                receipt.sha256
            )
        }

        let stageAData = try Data(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    observation
                        .stageAReceiptRelativePath
                )
        )
        let stageAReceipt =
            try JSONDecoder().decode(
                PrimeNativeNeuralGateContractReceipt
                    .self,
                from: stageAData
            )
        XCTAssertEqual(
            stageAReceipt.artifactKind,
            Observation.stageAReceiptArtifactKind
        )
        XCTAssertEqual(
            stageAReceipt.claimScope,
            Observation.stageAReceiptClaimScope
        )
        XCTAssertEqual(
            stageAReceipt.planSHA256,
            Observation.stageAReceiptPlanSHA256
        )
        XCTAssertEqual(
            stageAReceipt.outcome.rawValue,
            "PASS"
        )
        XCTAssertTrue(
            stageAReceipt.freshProcessReplayExact
        )
        XCTAssertTrue(
            stageAReceipt
                .parentFullCorpusReplayValidated
        )

        let fullCorpusData = try Data(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    observation
                        .fullCorpusReplayReceiptRelativePath
                )
        )
        let fullCorpusReceipt =
            try JSONDecoder().decode(
                PrimeNativeCorpusReplayReceipt.self,
                from: fullCorpusData
            )
        XCTAssertEqual(
            fullCorpusReceipt.artifactKind,
            Observation
                .fullCorpusReplayReceiptArtifactKind
        )
        XCTAssertEqual(
            fullCorpusReceipt.claimScope,
            Observation
                .fullCorpusReplayReceiptClaimScope
        )
        XCTAssertEqual(
            fullCorpusReceipt.planSHA256,
            Observation
                .fullCorpusReplayReceiptPlanSHA256
        )
        XCTAssertEqual(
            fullCorpusReceipt.outcome.rawValue,
            "PASS"
        )
        XCTAssertTrue(
            fullCorpusReceipt.freshProcessReplayExact
        )
        XCTAssertEqual(
            fullCorpusReceipt.regeneratedRowCount,
            155_648
        )
        XCTAssertEqual(
            fullCorpusReceipt.regradedRowCount,
            155_648
        )
    }

    func testTargetTokenBindingHasExactDomainSeparatedKnownAnswer()
        throws
    {
        let data =
            try Observation.targetTokenBindingData(
                tokenIDs: [321]
            )
        XCTAssertEqual(
            data.map {
                String(format: "%02x", $0)
            }.joined(),
            "5052494d454346543101410046"
        )
        XCTAssertEqual(
            sha256(data),
            "62f7a99efa386b461caeb8a26c3e4b83ab21abdd69a33d2e358118a6ff14309e"
        )
    }

    func testCanonicalMutationCannotRetainFixtureAuthority()
        throws
    {
        let observation =
            try Self.frozenObservation.get()
        let data = try observation.canonicalData()
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        )
        object["ordered_row_ids_sha256"] =
            String(repeating: "0", count: 64)
        let mutated = try JSONDecoder().decode(
            Observation.self,
            from:
                JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
        )
        XCTAssertThrowsError(
            try mutated.validateFrozen()
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateCorrectedFixtureObservationError,
                .frozenGoldenDrift
            )
        }
    }

    func testTargetGraphKeepsFixtureAuthorityOutOfCorrectedMechanics()
        throws
    {
        let package = withoutWhitespace(
            try String(
                contentsOf:
                    repositoryRoot
                    .appendingPathComponent("Package.swift"),
                encoding: .utf8
            )
        )
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateCorrectedFixtureAuthority",dependencies:["PrimeNativeCorpusReplayMechanics","PrimeNativeNeuralGateCorrectedMechanics","PrimeNativeNeuralGateCorrectedEvaluationMechanics",])"#
            )
        )
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateCorrectedMechanics",dependencies:["PrimeNativeNeuralGateReplayMechanics",])"#
            )
        )
        XCTAssertFalse(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateCorrectedMechanics",dependencies:["PrimeNativeCorpusReplayMechanics""#
            )
        )
        let sourceBinding =
            PrimeNativeNeuralGateFixtureReplayPlan
            .frozenV3.sourceExecutionBinding
        let fixtureRule = try XCTUnwrap(
            sourceBinding.targetClosureRules.first {
                $0.targetName
                    == "PrimeNativeNeuralGateCorrectedFixtureAuthority"
            }
        )
        XCTAssertEqual(
            fixtureRule.directLocalDependencyNames,
            [
                "PrimeNativeCorpusReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMechanics",
            ]
        )
        XCTAssertTrue(
            sourceBinding.processBindingRules
                .allSatisfy {
                    !$0.exactTransitiveLocalTargetNames
                        .contains(
                            "PrimeNativeNeuralGateCorrectedFixtureAuthority"
                        )
                        && !$0
                        .exactTransitiveLocalTargetNames
                        .contains(
                            "PrimeNativeNeuralGateCorrectedMechanics"
                        )
                }
        )

        let source = try String(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    "Sources/PrimeNativeNeuralGateCorrectedFixtureAuthority/PrimeNativeNeuralGateCorrectedFixtureObservation.swift"
                ),
            encoding: .utf8
        )
        for forbidden in [
            "import PythonKit",
            "import MLX",
            "import NeuralKit",
            "import PMHNP",
            "Foundation.Process",
            "Process(",
            "posix_spawn",
            "system(",
            "popen(",
            "/bin/sh",
            "/bin/zsh",
            "FileHandle",
            "FileManager",
            "try!",
            "precondition(",
            "preconditionFailure(",
            ".write(to:",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "fixture authority admits forbidden runtime or I/O: \(forbidden)"
            )
        }
    }

    private func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map {
            String(format: "%02x", $0)
        }.joined()
    }

    private func withoutWhitespace(
        _ source: String
    ) -> String {
        String(
            source.filter {
                !$0.isWhitespace
            }
        )
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
