import PrimeNativeNeuralGateCorrectedMutationSurfaceContracts
import PrimeNativeNeuralGateCorrectedMutationRecordContracts

public enum PrimeNativeNeuralGateCorrectedMutationProducerError:
    Error,
    Equatable,
    Sendable
{
    case invalidBaseline
    case invalidProducedBatch
    case transformationDidNotChangeExactlyOneControl
}

/// In-memory producer mechanics only. The identity is for the outer caller;
/// it is deliberately not an input to the independent detector.
public struct PrimeNativeNeuralGateCorrectedMutationProducedTriplet:
    Equatable,
    Sendable
{
    public let identity:
        PrimeNativeNeuralGateCorrectedMutationIdentity
    public let baseline:
        PrimeNativeNeuralGateBoundCorrectedControlSurface
    public let mutated:
        PrimeNativeNeuralGateBoundCorrectedControlSurface
    public let restored:
        PrimeNativeNeuralGateBoundCorrectedControlSurface

    fileprivate init(
        identity:
            PrimeNativeNeuralGateCorrectedMutationIdentity,
        baseline:
            PrimeNativeNeuralGateBoundCorrectedControlSurface,
        mutated:
            PrimeNativeNeuralGateBoundCorrectedControlSurface,
        restored:
            PrimeNativeNeuralGateBoundCorrectedControlSurface
    ) {
        self.identity = identity
        self.baseline = baseline
        self.mutated = mutated
        self.restored = restored
    }

    public var blindTriplet:
        PrimeNativeNeuralGateBlindCorrectedMutationTriplet
    {
        PrimeNativeNeuralGateBlindCorrectedMutationTriplet(
            baseline: baseline,
            mutated: mutated,
            restored: restored
        )
    }
}

public enum PrimeNativeNeuralGateCorrectedMutationProducer {
    public static func produceBatch(
        baseline:
            PrimeNativeNeuralGateCorrectedControlMaterial
    ) throws -> [PrimeNativeNeuralGateCorrectedMutationProducedTriplet] {
        let contract =
            PrimeNativeNeuralGateCorrectedMutationRecordContract
            .frozenV1
        try contract.validate()
        let batch = try contract.orderedMutationCatalog.map {
            try produce(
                mutationID: $0.mutationID,
                baseline: baseline
            )
        }
        guard batch.count
                == PrimeNativeNeuralGateCorrectedMutationSurfaceContract
                .exactBlindBatchCount,
              let common = batch.first,
              batch.allSatisfy({
                  $0.baseline == common.baseline
                      && $0.restored == common.baseline
              })
        else {
            throw PrimeNativeNeuralGateCorrectedMutationProducerError
                .invalidProducedBatch
        }
        for first in batch.indices {
            for second in batch.indices where second > first {
                guard batch[first].mutated.bytes
                        != batch[second].mutated.bytes
                else {
                    throw PrimeNativeNeuralGateCorrectedMutationProducerError
                        .invalidProducedBatch
                }
            }
        }
        return batch
    }

    public static func produce(
        mutationID:
            PrimeNativeNeuralGateCorrectedMutationCaseID,
        baseline:
            PrimeNativeNeuralGateCorrectedControlMaterial
    ) throws -> PrimeNativeNeuralGateCorrectedMutationProducedTriplet {
        guard baseline.isExactBaselineControlSet()
        else {
            throw PrimeNativeNeuralGateCorrectedMutationProducerError
                .invalidBaseline
        }
        let identity =
            try PrimeNativeNeuralGateCorrectedMutationRecordContract
            .frozenV1.identity(mutationID: mutationID)
        let mutated = try apply(
            mutationID,
            to: baseline
        )
        guard controlDifferenceCount(
            baseline,
            mutated
        ) == 1 else {
            throw PrimeNativeNeuralGateCorrectedMutationProducerError
                .transformationDidNotChangeExactlyOneControl
        }
        let baselineSurface =
            try PrimeNativeNeuralGateCorrectedControlSurfaceBinder
            .bind(baseline)
        let mutatedSurface =
            try PrimeNativeNeuralGateCorrectedControlSurfaceBinder
            .bind(mutated)
        let restoredSurface =
            try PrimeNativeNeuralGateCorrectedControlSurfaceBinder
            .bind(baseline)
        guard baselineSurface.bytes != mutatedSurface.bytes,
              baselineSurface == restoredSurface,
              baselineSurface.binding.surfaceSHA256
                != mutatedSurface.binding.surfaceSHA256,
              baselineSurface.binding
                .invariantGlobalStreamSHA256
                != mutatedSurface.binding
                .invariantGlobalStreamSHA256,
              baselineSurface.binding.directFingerprint
                != mutatedSurface.binding.directFingerprint,
              baselineSurface.binding.acceleratedFingerprint
                != mutatedSurface.binding
                .acceleratedFingerprint
        else {
            throw PrimeNativeNeuralGateCorrectedMutationProducerError
                .transformationDidNotChangeExactlyOneControl
        }
        return PrimeNativeNeuralGateCorrectedMutationProducedTriplet(
            identity: identity,
            baseline: baselineSurface,
            mutated: mutatedSurface,
            restored: restoredSurface
        )
    }

    private static func apply(
        _ mutationID:
            PrimeNativeNeuralGateCorrectedMutationCaseID,
        to baseline:
            PrimeNativeNeuralGateCorrectedControlMaterial
    ) throws -> PrimeNativeNeuralGateCorrectedControlMaterial {
        try PrimeNativeNeuralGateCorrectedControlMaterial(
            commonCaptureScheduleReferenceSHA256:
                baseline
                .commonCaptureScheduleReferenceSHA256,
            branchCaptureScheduleReferenceSHA256:
                baseline
                .branchCaptureScheduleReferenceSHA256,
            targetValueAffectsRawIdentity:
                mutationID
                    == .targetValueChangesRawExecution
                    ? true
                    : baseline
                    .targetValueAffectsRawIdentity,
            targetLengthAffectsRawIdentity:
                mutationID
                    == .targetLengthChangesRawExecution
                    ? true
                    : baseline
                    .targetLengthAffectsRawIdentity,
            predictionExpectedCompletionPresent:
                mutationID
                    == .expectedCompletionInjectedIntoPrediction
                    ? true
                    : baseline
                    .predictionExpectedCompletionPresent,
            predictionRowIDPresent:
                mutationID
                    == .correlationRowIDInjectedIntoPrediction
                    ? true
                    : baseline.predictionRowIDPresent,
            predictionSplitPresent:
                mutationID
                    == .correlationSplitInjectedIntoPrediction
                    ? true
                    : baseline.predictionSplitPresent,
            predictionSemanticFamilyPresent:
                mutationID
                    == .correlationSemanticFamilyInjectedIntoPrediction
                    ? true
                    : baseline
                    .predictionSemanticFamilyPresent,
            promptGrouping:
                mutationID
                    == .targetDependentPromptGrouping
                    ? .targetDependent
                    : baseline.promptGrouping,
            decisionBudget:
                mutationID
                    == .targetDependentDecisionBudget
                    ? .targetDependent
                    : baseline.decisionBudget,
            eosAvailableAtEveryDecision:
                mutationID
                    == .eosUnavailableAtDecision
                    ? false
                    : baseline
                    .eosAvailableAtEveryDecision,
            completionSupport:
                mutationID
                    == .completionSupportNarrowed
                    ? .eosAndRestrictedByteVocabulary
                    : baseline.completionSupport,
            fixedDecisionCap:
                mutationID == .fixedCapDrift
                    ? 63
                    : baseline.fixedDecisionCap,
            termination:
                mutationID
                    == .targetDependentTermination
                    ? .targetDependent
                    : baseline.termination,
            rowInclusion:
                mutationID
                    == .targetDependentRowInclusion
                    ? .targetDependent
                    : baseline.rowInclusion,
            replicateSeed: baseline.replicateSeed,
            replicateSeedScope:
                mutationID
                    == .rowDependentEvaluationSeed
                    ? .rowDependent
                    : baseline.replicateSeedScope,
            rowState:
                mutationID
                    == .retainedStateChangesPermutedRowTrace
                    ? .retainedAcrossRows
                    : baseline.rowState
        )
    }

    private static func controlDifferenceCount(
        _ lhs:
            PrimeNativeNeuralGateCorrectedControlMaterial,
        _ rhs:
            PrimeNativeNeuralGateCorrectedControlMaterial
    ) -> Int {
        [
            lhs.commonCaptureScheduleReferenceSHA256
                != rhs.commonCaptureScheduleReferenceSHA256,
            lhs.branchCaptureScheduleReferenceSHA256
                != rhs.branchCaptureScheduleReferenceSHA256,
            lhs.copiedReferenceAuthorityObserved
                != rhs.copiedReferenceAuthorityObserved,
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
            lhs.replicateSeed != rhs.replicateSeed,
            lhs.replicateSeedScope
                != rhs.replicateSeedScope,
            lhs.rowState != rhs.rowState,
        ].filter { $0 }.count
    }
}
