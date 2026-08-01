import Foundation
import XCTest
import PrimeNativeNeuralGateCorrectedMutationDetector
import PrimeNativeNeuralGateCorrectedMutationSurfaceContracts

final class PrimeNativeNeuralGateCorrectedMutationDetectorTests:
    XCTestCase
{
    func testValidBlindBatchClassifiesAllFifteenWithoutIdentityInput()
        throws
    {
        let fixtures = try makeFixtures()
        let reports =
            try PrimeNativeNeuralGateCorrectedMutationDetector
            .detectBatch(fixtures.map(\.triplet))

        XCTAssertEqual(
            fixtures.count,
            PrimeNativeNeuralGateCorrectedMutationSurfaceContract
                .exactBlindBatchCount
        )
        XCTAssertEqual(reports.count, fixtures.count)
        for (fixture, report) in zip(fixtures, reports) {
            XCTAssertEqual(
                report.orderedLegObservations.map(\.legID),
                PrimeNativeNeuralGateCorrectedControlLegID
                    .allCases
            )
            XCTAssertEqual(
                report.failedLegIDs,
                [fixture.scenario.expectedFailedLegID]
            )
        }
        let common = try XCTUnwrap(fixtures.first).triplet
        XCTAssertTrue(
            fixtures.allSatisfy {
                $0.triplet.baseline == common.baseline
                    && $0.triplet.restored == common.baseline
            }
        )
        XCTAssertEqual(
            Set(
                fixtures.map {
                    $0.triplet.mutated.binding.surfaceSHA256
                }
            ).count,
            fixtures.count
        )
    }

    func testBatchRejectsTooFewAndTooManyEntries() throws {
        let batch = try makeFixtures().map(\.triplet)
        assertBatchError(
            .batchCountMismatch(14),
            batch: Array(batch.dropLast())
        )
        assertBatchError(
            .batchCountMismatch(16),
            batch: batch + [try XCTUnwrap(batch.first)]
        )
    }

    func testBatchRejectsPerEntryReferenceAndSeedContexts()
        throws
    {
        let fixtures = try makeFixtures()
        let referenceBaseline = try makeBaseline(common: "c")
        let seedBaseline = try makeBaseline(seed: 2_718)

        for alternate in [referenceBaseline, seedBaseline] {
            var batch = fixtures.map(\.triplet)
            let scenario = fixtures[4].scenario
            let alternateSurface = try bind(alternate)
            batch[4] =
                PrimeNativeNeuralGateBlindCorrectedMutationTriplet(
                    baseline: alternateSurface,
                    mutated: try bind(
                        independentlyMutated(
                            alternate,
                            for: scenario
                        )
                    ),
                    restored: alternateSurface
                )
            assertBatchError(
                .batchCommonContextMismatch,
                batch: batch
            )
        }
    }

    func testBatchRejectsMutatedOnlyReferenceAndSeedDrift()
        throws
    {
        let fixtures = try makeFixtures()
        for alternate in [
            try makeBaseline(common: "c"),
            try makeBaseline(seed: 2_718),
        ] {
            var batch = fixtures.map(\.triplet)
            batch[4] =
                PrimeNativeNeuralGateBlindCorrectedMutationTriplet(
                    baseline: batch[4].baseline,
                    mutated: try bind(
                        independentlyMutated(
                            alternate,
                            for: fixtures[4].scenario
                        )
                    ),
                    restored: batch[4].restored
                )
            assertBatchError(
                .immutableContextChanged,
                batch: batch
            )
        }
    }

    func testBatchRejectsDuplicateMutatedSurfaces() throws {
        var batch = try makeFixtures().map(\.triplet)
        batch[14] =
            PrimeNativeNeuralGateBlindCorrectedMutationTriplet(
                baseline: batch[14].baseline,
                mutated: batch[0].mutated,
                restored: batch[14].restored
            )
        assertBatchError(
            .duplicateMutatedSurface,
            batch: batch
        )
    }

    func testBatchClassificationIsReversalAndRotationInvariant()
        throws
    {
        let batch = try makeFixtures().map(\.triplet)
        let expected = try keyedReports(batch)
        let reversed = Array(batch.reversed())
        XCTAssertEqual(try keyedReports(reversed), expected)

        let rotation = 4
        let rotated = Array(batch.dropFirst(rotation))
            + Array(batch.prefix(rotation))
        XCTAssertEqual(try keyedReports(rotated), expected)

        var transpositionCount = 0
        for first in batch.indices {
            for second in batch.indices where second > first {
                var transposed = batch
                transposed.swapAt(first, second)
                XCTAssertEqual(
                    try keyedReports(transposed),
                    expected,
                    "transposition \(first)<->\(second)"
                )
                transpositionCount += 1
            }
        }
        XCTAssertEqual(transpositionCount, 105)
    }

    func testBatchRejectsMutationChangingTwoControls()
        throws
    {
        let baseline = try makeBaseline()
        var controls = Controls(baseline)
        controls.targetValueAffectsRawIdentity = true
        controls.promptGrouping = .targetDependent
        var batch = try makeFixtures(
            baseline: baseline
        ).map(\.triplet)
        batch[0] =
            PrimeNativeNeuralGateBlindCorrectedMutationTriplet(
                baseline: batch[0].baseline,
                mutated: try bind(makeMaterial(controls)),
                restored: batch[0].restored
            )
        assertBatchError(
            .mutationChangedControlCount(2),
            batch: batch
        )
    }

    func testBatchRejectsTamperedBindingAndForgedSZPair()
        throws
    {
        var batch = try makeFixtures().map(\.triplet)
        let target = batch[7].mutated
        let common = batch[7].baseline
        let forged =
            PrimeNativeNeuralGateCorrectedControlSurfaceBinding(
                surfaceByteCount:
                    target.binding.surfaceByteCount,
                surfaceSHA256: target.binding.surfaceSHA256,
                invariantGlobalStreamSHA256:
                    target.binding.invariantGlobalStreamSHA256,
                directFingerprint:
                    common.binding.directFingerprint,
                acceleratedFingerprint:
                    common.binding.acceleratedFingerprint
            )
        batch[7] =
            PrimeNativeNeuralGateBlindCorrectedMutationTriplet(
                baseline: batch[7].baseline,
                mutated:
                    PrimeNativeNeuralGateBoundCorrectedControlSurface(
                        bytes: target.bytes,
                        binding: forged
                    ),
                restored: batch[7].restored
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCorrectedMutationDetector
                .detectBatch(batch)
        ) {
            XCTAssertEqual(
                $0 as? PrimeNativeNeuralGateMutationSurfaceError,
                .invalidSurfaceBinding
            )
        }
    }

    func testBatchRejectsMalformedMutatedSurface() throws {
        var batch = try makeFixtures().map(\.triplet)
        let target = batch[9].mutated
        var bytes = target.bytes
        bytes[bytes.startIndex] = 0
        batch[9] =
            PrimeNativeNeuralGateBlindCorrectedMutationTriplet(
                baseline: batch[9].baseline,
                mutated:
                    PrimeNativeNeuralGateBoundCorrectedControlSurface(
                        bytes: bytes,
                        binding: target.binding
                    ),
                restored: batch[9].restored
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCorrectedMutationDetector
                .detectBatch(batch)
        ) {
            XCTAssertEqual(
                $0 as? PrimeNativeNeuralGateMutationSurfaceError,
                .invalidMagic
            )
        }
    }

    private func keyedReports(
        _ batch:
            [PrimeNativeNeuralGateBlindCorrectedMutationTriplet]
    ) throws -> [String: [PrimeNativeNeuralGateCorrectedControlLegID]] {
        let reports =
            try PrimeNativeNeuralGateCorrectedMutationDetector
            .detectBatch(batch)
        return Dictionary(
            uniqueKeysWithValues: zip(batch, reports).map {
                (
                    surfaceKey($0.0.mutated),
                    $0.1.failedLegIDs
                )
            }
        )
    }

    private func surfaceKey(
        _ surface:
            PrimeNativeNeuralGateBoundCorrectedControlSurface
    ) -> String {
        surface.binding.surfaceSHA256
            + ":"
            + surface.bytes.base64EncodedString()
    }

    private func assertBatchError(
        _ expected:
            PrimeNativeNeuralGateCorrectedMutationDetectorError,
        batch:
            [PrimeNativeNeuralGateBlindCorrectedMutationTriplet],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateCorrectedMutationDetector
                .detectBatch(batch),
            file: file,
            line: line
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateCorrectedMutationDetectorError,
                expected,
                file: file,
                line: line
            )
        }
    }

    private func makeFixtures(
        baseline: PrimeNativeNeuralGateCorrectedControlMaterial? = nil
    ) throws -> [Fixture] {
        let baseline = try baseline ?? makeBaseline()
        let common = try bind(baseline)
        return try MutationScenario.allCases.map { scenario in
            Fixture(
                scenario: scenario,
                triplet:
                    PrimeNativeNeuralGateBlindCorrectedMutationTriplet(
                        baseline: common,
                        mutated: try bind(
                            independentlyMutated(
                                baseline,
                                for: scenario
                            )
                        ),
                        restored: common
                    )
            )
        }
    }

    private func bind(
        _ material: PrimeNativeNeuralGateCorrectedControlMaterial
    ) throws -> PrimeNativeNeuralGateBoundCorrectedControlSurface {
        try PrimeNativeNeuralGateCorrectedControlSurfaceBinder
            .bind(material)
    }

    private func makeBaseline(
        common: Character = "a",
        branch: Character = "b",
        seed: UInt32 = 1_618
    ) throws -> PrimeNativeNeuralGateCorrectedControlMaterial {
        try .baseline(
            commonCaptureScheduleReferenceSHA256:
                String(repeating: String(common), count: 64),
            branchCaptureScheduleReferenceSHA256:
                String(repeating: String(branch), count: 64),
            replicateSeed: seed
        )
    }

    private func independentlyMutated(
        _ baseline: PrimeNativeNeuralGateCorrectedControlMaterial,
        for scenario: MutationScenario
    ) throws -> PrimeNativeNeuralGateCorrectedControlMaterial {
        var controls = Controls(baseline)
        switch scenario {
        case .targetValue:
            controls.targetValueAffectsRawIdentity = true
        case .targetLength:
            controls.targetLengthAffectsRawIdentity = true
        case .expectedCompletionPresence:
            controls.predictionExpectedCompletionPresent = true
        case .promptGrouping:
            controls.promptGrouping = .targetDependent
        case .decisionBudget:
            controls.decisionBudget = .targetDependent
        case .eosAvailability:
            controls.eosAvailableAtEveryDecision = false
        case .completionSupport:
            controls.completionSupport =
                .eosAndRestrictedByteVocabulary
        case .fixedCap:
            controls.fixedDecisionCap = 63
        case .termination:
            controls.termination = .targetDependent
        case .rowInclusion:
            controls.rowInclusion = .targetDependent
        case .rowIDPresence:
            controls.predictionRowIDPresent = true
        case .splitPresence:
            controls.predictionSplitPresent = true
        case .semanticFamilyPresence:
            controls.predictionSemanticFamilyPresent = true
        case .replicateSeedScope:
            controls.replicateSeedScope = .rowDependent
        case .rowState:
            controls.rowState = .retainedAcrossRows
        }
        return try makeMaterial(controls)
    }

    private func makeMaterial(
        _ controls: Controls
    ) throws -> PrimeNativeNeuralGateCorrectedControlMaterial {
        try PrimeNativeNeuralGateCorrectedControlMaterial(
            commonCaptureScheduleReferenceSHA256:
                controls.commonReference,
            branchCaptureScheduleReferenceSHA256:
                controls.branchReference,
            targetValueAffectsRawIdentity:
                controls.targetValueAffectsRawIdentity,
            targetLengthAffectsRawIdentity:
                controls.targetLengthAffectsRawIdentity,
            predictionExpectedCompletionPresent:
                controls.predictionExpectedCompletionPresent,
            predictionRowIDPresent:
                controls.predictionRowIDPresent,
            predictionSplitPresent:
                controls.predictionSplitPresent,
            predictionSemanticFamilyPresent:
                controls.predictionSemanticFamilyPresent,
            promptGrouping: controls.promptGrouping,
            decisionBudget: controls.decisionBudget,
            eosAvailableAtEveryDecision:
                controls.eosAvailableAtEveryDecision,
            completionSupport: controls.completionSupport,
            fixedDecisionCap: controls.fixedDecisionCap,
            termination: controls.termination,
            rowInclusion: controls.rowInclusion,
            replicateSeed: controls.replicateSeed,
            replicateSeedScope: controls.replicateSeedScope,
            rowState: controls.rowState
        )
    }

    private struct Fixture {
        let scenario: MutationScenario
        let triplet:
            PrimeNativeNeuralGateBlindCorrectedMutationTriplet
    }

    private enum MutationScenario: CaseIterable {
        case targetValue
        case targetLength
        case expectedCompletionPresence
        case promptGrouping
        case decisionBudget
        case eosAvailability
        case completionSupport
        case fixedCap
        case termination
        case rowInclusion
        case rowIDPresence
        case splitPresence
        case semanticFamilyPresence
        case replicateSeedScope
        case rowState

        var expectedFailedLegID:
            PrimeNativeNeuralGateCorrectedControlLegID
        {
            switch self {
            case .targetValue:
                .targetValueIndependence
            case .targetLength:
                .targetLengthIndependence
            case .expectedCompletionPresence,
                 .rowIDPresence,
                 .splitPresence,
                 .semanticFamilyPresence:
                .predictionInputExclusion
            case .promptGrouping:
                .promptGrouping
            case .decisionBudget:
                .decisionBudget
            case .eosAvailability:
                .eosAvailability
            case .completionSupport:
                .completionSupport
            case .fixedCap:
                .fixedCap
            case .termination:
                .terminationIndependence
            case .rowInclusion:
                .rowInclusionIndependence
            case .replicateSeedScope:
                .replicateSeedScope
            case .rowState:
                .rowOrderStateIndependence
            }
        }
    }

    private struct Controls {
        var commonReference: String
        var branchReference: String
        var targetValueAffectsRawIdentity: Bool
        var targetLengthAffectsRawIdentity: Bool
        var predictionExpectedCompletionPresent: Bool
        var predictionRowIDPresent: Bool
        var predictionSplitPresent: Bool
        var predictionSemanticFamilyPresent: Bool
        var promptGrouping:
            PrimeNativeNeuralGatePromptGroupingControl
        var decisionBudget:
            PrimeNativeNeuralGateDecisionBudgetControl
        var eosAvailableAtEveryDecision: Bool
        var completionSupport:
            PrimeNativeNeuralGateCompletionSupportControl
        var fixedDecisionCap: UInt16
        var termination:
            PrimeNativeNeuralGateTerminationControl
        var rowInclusion:
            PrimeNativeNeuralGateRowInclusionControl
        var replicateSeed: UInt32
        var replicateSeedScope:
            PrimeNativeNeuralGateReplicateSeedScopeControl
        var rowState: PrimeNativeNeuralGateRowStateControl

        init(
            _ material:
                PrimeNativeNeuralGateCorrectedControlMaterial
        ) {
            commonReference =
                material.commonCaptureScheduleReferenceSHA256
            branchReference =
                material.branchCaptureScheduleReferenceSHA256
            targetValueAffectsRawIdentity =
                material.targetValueAffectsRawIdentity
            targetLengthAffectsRawIdentity =
                material.targetLengthAffectsRawIdentity
            predictionExpectedCompletionPresent =
                material.predictionExpectedCompletionPresent
            predictionRowIDPresent =
                material.predictionRowIDPresent
            predictionSplitPresent =
                material.predictionSplitPresent
            predictionSemanticFamilyPresent =
                material.predictionSemanticFamilyPresent
            promptGrouping = material.promptGrouping
            decisionBudget = material.decisionBudget
            eosAvailableAtEveryDecision =
                material.eosAvailableAtEveryDecision
            completionSupport = material.completionSupport
            fixedDecisionCap = material.fixedDecisionCap
            termination = material.termination
            rowInclusion = material.rowInclusion
            replicateSeed = material.replicateSeed
            replicateSeedScope = material.replicateSeedScope
            rowState = material.rowState
        }
    }
}
