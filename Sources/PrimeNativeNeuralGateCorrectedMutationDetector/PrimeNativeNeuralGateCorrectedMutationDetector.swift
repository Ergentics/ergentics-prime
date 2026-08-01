import PrimeNativeNeuralGateCorrectedMutationSurfaceContracts

public enum PrimeNativeNeuralGateCorrectedMutationDetectorError:
    Error,
    Equatable,
    Sendable
{
    case batchCountMismatch(Int)
    case batchCommonContextMismatch
    case duplicateMutatedSurface
    case baselineFailed(
        [PrimeNativeNeuralGateCorrectedControlLegID]
    )
    case mutationUnchanged
    case immutableContextChanged
    case mutationChangedControlCount(Int)
    case mutationBindingDidNotDiverge
    case noFailedLegs
    case restorationMismatch
    case restoredFailed(
        [PrimeNativeNeuralGateCorrectedControlLegID]
    )
}

public struct PrimeNativeNeuralGateCorrectedControlLegObservation:
    Equatable,
    Sendable
{
    public let legID:
        PrimeNativeNeuralGateCorrectedControlLegID
    public let passed: Bool

    fileprivate init(
        legID:
            PrimeNativeNeuralGateCorrectedControlLegID,
        passed: Bool
    ) {
        self.legID = legID
        self.passed = passed
    }
}

/// Independent in-memory classification. This value contains no mutation
/// identity, expected failure, verdict, PASS, receipt, or execution claim.
public struct PrimeNativeNeuralGateCorrectedMutationDetectionReport:
    Equatable,
    Sendable
{
    public let orderedLegObservations:
        [PrimeNativeNeuralGateCorrectedControlLegObservation]
    public let failedLegIDs:
        [PrimeNativeNeuralGateCorrectedControlLegID]

    fileprivate init(
        orderedLegObservations:
            [PrimeNativeNeuralGateCorrectedControlLegObservation]
    ) {
        self.orderedLegObservations =
            orderedLegObservations
        failedLegIDs = orderedLegObservations
            .filter { !$0.passed }
            .map(\.legID)
    }
}

public enum PrimeNativeNeuralGateCorrectedMutationDetector {
    public static func detectBatch(
        _ batch:
            [PrimeNativeNeuralGateBlindCorrectedMutationTriplet]
    ) throws -> [PrimeNativeNeuralGateCorrectedMutationDetectionReport] {
        guard batch.count
                == PrimeNativeNeuralGateCorrectedMutationSurfaceContract
                .exactBlindBatchCount
        else {
            throw PrimeNativeNeuralGateCorrectedMutationDetectorError
                .batchCountMismatch(batch.count)
        }
        guard let common = batch.first,
              batch.allSatisfy({
                  $0.baseline == common.baseline
                      && $0.restored == common.baseline
              })
        else {
            throw PrimeNativeNeuralGateCorrectedMutationDetectorError
                .batchCommonContextMismatch
        }
        for first in batch.indices {
            for second in batch.indices where second > first {
                guard batch[first].mutated.bytes
                        != batch[second].mutated.bytes
                else {
                    throw PrimeNativeNeuralGateCorrectedMutationDetectorError
                        .duplicateMutatedSurface
                }
            }
        }
        return try batch.map(detectSingle)
    }

    private static func detectSingle(
        _ triplet:
            PrimeNativeNeuralGateBlindCorrectedMutationTriplet
    ) throws -> PrimeNativeNeuralGateCorrectedMutationDetectionReport {
        let baseline = triplet.baseline
        let mutated = triplet.mutated
        let restored = triplet.restored
        let baselineMaterial =
            try PrimeNativeNeuralGateCorrectedControlSurfaceBinder
            .validateAndDecode(baseline)
        let mutatedMaterial =
            try PrimeNativeNeuralGateCorrectedControlSurfaceBinder
            .validateAndDecode(mutated)
        let restoredMaterial =
            try PrimeNativeNeuralGateCorrectedControlSurfaceBinder
            .validateAndDecode(restored)

        let baselineObservations = evaluate(
            baselineMaterial
        )
        let baselineFailures = failures(
            baselineObservations
        )
        guard baselineFailures.isEmpty else {
            throw PrimeNativeNeuralGateCorrectedMutationDetectorError
                .baselineFailed(baselineFailures)
        }
        guard baseline.bytes != mutated.bytes else {
            throw PrimeNativeNeuralGateCorrectedMutationDetectorError
                .mutationUnchanged
        }
        guard baselineMaterial
                .commonCaptureScheduleReferenceSHA256
                == mutatedMaterial
                .commonCaptureScheduleReferenceSHA256,
              baselineMaterial
                .branchCaptureScheduleReferenceSHA256
                == mutatedMaterial
                .branchCaptureScheduleReferenceSHA256,
              baselineMaterial.replicateSeed
                == mutatedMaterial.replicateSeed
        else {
            throw PrimeNativeNeuralGateCorrectedMutationDetectorError
                .immutableContextChanged
        }
        let changedControlCount = controlDifferenceCount(
            baselineMaterial,
            mutatedMaterial
        )
        guard changedControlCount == 1 else {
            throw PrimeNativeNeuralGateCorrectedMutationDetectorError
                .mutationChangedControlCount(
                    changedControlCount
                )
        }
        guard baseline.binding.surfaceSHA256
                != mutated.binding.surfaceSHA256,
              baseline.binding.invariantGlobalStreamSHA256
                != mutated.binding.invariantGlobalStreamSHA256,
              baseline.binding.directFingerprint
                != mutated.binding.directFingerprint,
              baseline.binding.acceleratedFingerprint
                != mutated.binding.acceleratedFingerprint
        else {
            throw PrimeNativeNeuralGateCorrectedMutationDetectorError
                .mutationBindingDidNotDiverge
        }
        guard baseline == restored else {
            throw PrimeNativeNeuralGateCorrectedMutationDetectorError
                .restorationMismatch
        }
        let restoredObservations = evaluate(
            restoredMaterial
        )
        let restoredFailures = failures(
            restoredObservations
        )
        guard restoredFailures.isEmpty else {
            throw PrimeNativeNeuralGateCorrectedMutationDetectorError
                .restoredFailed(restoredFailures)
        }
        let mutatedObservations = evaluate(
            mutatedMaterial
        )
        guard !failures(mutatedObservations).isEmpty
        else {
            throw PrimeNativeNeuralGateCorrectedMutationDetectorError
                .noFailedLegs
        }
        return PrimeNativeNeuralGateCorrectedMutationDetectionReport(
            orderedLegObservations:
                mutatedObservations
        )
    }

    private static func evaluate(
        _ material:
            PrimeNativeNeuralGateCorrectedControlMaterial
    ) -> [PrimeNativeNeuralGateCorrectedControlLegObservation] {
        let observations = [
            PrimeNativeNeuralGateCorrectedControlLegObservation(
                legID: .targetValueIndependence,
                passed:
                    !material
                    .targetValueAffectsRawIdentity
            ),
            PrimeNativeNeuralGateCorrectedControlLegObservation(
                legID: .targetLengthIndependence,
                passed:
                    !material
                    .targetLengthAffectsRawIdentity
            ),
            PrimeNativeNeuralGateCorrectedControlLegObservation(
                legID: .predictionInputExclusion,
                passed:
                    !material
                    .predictionExpectedCompletionPresent
                    && !material.predictionRowIDPresent
                    && !material.predictionSplitPresent
                    && !material
                    .predictionSemanticFamilyPresent
            ),
            PrimeNativeNeuralGateCorrectedControlLegObservation(
                legID: .promptGrouping,
                passed:
                    material.promptGrouping
                    == .targetIndependent
            ),
            PrimeNativeNeuralGateCorrectedControlLegObservation(
                legID: .decisionBudget,
                passed:
                    material.decisionBudget
                    == .fixedPolicy
            ),
            PrimeNativeNeuralGateCorrectedControlLegObservation(
                legID: .eosAvailability,
                passed:
                    material
                    .eosAvailableAtEveryDecision
            ),
            PrimeNativeNeuralGateCorrectedControlLegObservation(
                legID: .completionSupport,
                passed:
                    material.completionSupport
                    == .eosAndFullByteVocabulary
            ),
            PrimeNativeNeuralGateCorrectedControlLegObservation(
                legID: .fixedCap,
                passed:
                    material.fixedDecisionCap == 64
            ),
            PrimeNativeNeuralGateCorrectedControlLegObservation(
                legID: .terminationIndependence,
                passed:
                    material.termination
                    == .eosOrFixedCap
            ),
            PrimeNativeNeuralGateCorrectedControlLegObservation(
                legID: .rowInclusionIndependence,
                passed:
                    material.rowInclusion
                    == .allSourceRows
            ),
            PrimeNativeNeuralGateCorrectedControlLegObservation(
                legID: .replicateSeedScope,
                passed:
                    material.replicateSeedScope
                    == .replicate
            ),
            PrimeNativeNeuralGateCorrectedControlLegObservation(
                legID: .rowOrderStateIndependence,
                passed:
                    material.rowState == .freshPerRow
            ),
        ]
        precondition(
            observations.map(\.legID)
                == PrimeNativeNeuralGateCorrectedControlLegID
                .allCases
        )
        return observations
    }

    private static func failures(
        _ observations:
            [PrimeNativeNeuralGateCorrectedControlLegObservation]
    ) -> [PrimeNativeNeuralGateCorrectedControlLegID] {
        observations
            .filter { !$0.passed }
            .map(\.legID)
    }

    private static func controlDifferenceCount(
        _ lhs:
            PrimeNativeNeuralGateCorrectedControlMaterial,
        _ rhs:
            PrimeNativeNeuralGateCorrectedControlMaterial
    ) -> Int {
        [
            lhs.targetValueAffectsRawIdentity
                != rhs.targetValueAffectsRawIdentity,
            lhs.targetLengthAffectsRawIdentity
                != rhs.targetLengthAffectsRawIdentity,
            lhs.predictionExpectedCompletionPresent
                != rhs.predictionExpectedCompletionPresent,
            lhs.predictionRowIDPresent
                != rhs.predictionRowIDPresent,
            lhs.predictionSplitPresent
                != rhs.predictionSplitPresent,
            lhs.predictionSemanticFamilyPresent
                != rhs.predictionSemanticFamilyPresent,
            lhs.promptGrouping != rhs.promptGrouping,
            lhs.decisionBudget != rhs.decisionBudget,
            lhs.eosAvailableAtEveryDecision
                != rhs.eosAvailableAtEveryDecision,
            lhs.completionSupport != rhs.completionSupport,
            lhs.fixedDecisionCap != rhs.fixedDecisionCap,
            lhs.termination != rhs.termination,
            lhs.rowInclusion != rhs.rowInclusion,
            lhs.replicateSeedScope
                != rhs.replicateSeedScope,
            lhs.rowState != rhs.rowState,
        ].filter { $0 }.count
    }
}
