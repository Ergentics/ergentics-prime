import Foundation
import PrimeNativeNeuralGateCorrectedMutationSurfaceContracts
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics

public enum PrimeNativeNeuralGateCorrectedMutationRecordContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case invalidMutationIdentity
}

public enum PrimeNativeNeuralGateCorrectedMutationCaseID:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case targetValueChangesRawExecution =
        "target_value_changes_raw_execution"
    case targetLengthChangesRawExecution =
        "target_length_changes_raw_execution"
    case expectedCompletionInjectedIntoPrediction =
        "expected_completion_injected_into_prediction"
    case targetDependentPromptGrouping =
        "target_dependent_prompt_grouping"
    case targetDependentDecisionBudget =
        "target_dependent_decision_budget"
    case eosUnavailableAtDecision =
        "eos_unavailable_at_decision"
    case completionSupportNarrowed =
        "completion_support_narrowed"
    case fixedCapDrift = "fixed_cap_drift"
    case targetDependentTermination =
        "target_dependent_termination"
    case targetDependentRowInclusion =
        "target_dependent_row_inclusion"
    case correlationRowIDInjectedIntoPrediction =
        "correlation_row_id_injected_into_prediction"
    case correlationSplitInjectedIntoPrediction =
        "correlation_split_injected_into_prediction"
    case correlationSemanticFamilyInjectedIntoPrediction =
        "correlation_semantic_family_injected_into_prediction"
    case rowDependentEvaluationSeed =
        "row_dependent_evaluation_seed"
    case retainedStateChangesPermutedRowTrace =
        "retained_state_changes_permuted_row_trace"

    public var expectedFailedLegID:
        PrimeNativeNeuralGateCorrectedControlLegID
    {
        switch self {
        case .targetValueChangesRawExecution:
            .targetValueIndependence
        case .targetLengthChangesRawExecution:
            .targetLengthIndependence
        case .expectedCompletionInjectedIntoPrediction,
             .correlationRowIDInjectedIntoPrediction,
             .correlationSplitInjectedIntoPrediction,
             .correlationSemanticFamilyInjectedIntoPrediction:
            .predictionInputExclusion
        case .targetDependentPromptGrouping:
            .promptGrouping
        case .targetDependentDecisionBudget:
            .decisionBudget
        case .eosUnavailableAtDecision:
            .eosAvailability
        case .completionSupportNarrowed:
            .completionSupport
        case .fixedCapDrift:
            .fixedCap
        case .targetDependentTermination:
            .terminationIndependence
        case .targetDependentRowInclusion:
            .rowInclusionIndependence
        case .rowDependentEvaluationSeed:
            .replicateSeedScope
        case .retainedStateChangesPermutedRowTrace:
            .rowOrderStateIndependence
        }
    }
}

public struct PrimeNativeNeuralGateCorrectedMutationCatalogEntry:
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    public let arm: PrimeNativeNeuralGateArtifactArm
    public let ordinal: UInt32
    public let mutationID:
        PrimeNativeNeuralGateCorrectedMutationCaseID
    public let exactAllowedFailedLegIDSets:
        [[PrimeNativeNeuralGateCorrectedControlLegID]]

    fileprivate init(
        ordinal: UInt32,
        mutationID:
            PrimeNativeNeuralGateCorrectedMutationCaseID
    ) {
        arm = .correctedFixedCapEOS
        self.ordinal = ordinal
        self.mutationID = mutationID
        exactAllowedFailedLegIDSets = [
            [mutationID.expectedFailedLegID],
        ]
    }

    private enum CodingKeys: String, CodingKey {
        case arm
        case ordinal
        case mutationID = "mutation_id"
        case exactAllowedFailedLegIDSets =
            "exact_allowed_failed_leg_id_sets"
    }
}

public struct PrimeNativeNeuralGateCorrectedMutationIdentity:
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    public let arm: PrimeNativeNeuralGateArtifactArm
    public let ordinal: UInt32
    public let mutationID:
        PrimeNativeNeuralGateCorrectedMutationCaseID
    public let exactAllowedFailedLegIDSets:
        [[PrimeNativeNeuralGateCorrectedControlLegID]]

    public init(
        arm: PrimeNativeNeuralGateArtifactArm,
        ordinal: UInt32,
        mutationID:
            PrimeNativeNeuralGateCorrectedMutationCaseID,
        exactAllowedFailedLegIDSets:
            [[PrimeNativeNeuralGateCorrectedControlLegID]]
    ) throws {
        guard let entry =
                PrimeNativeNeuralGateCorrectedMutationRecordContract
                .frozenV1.entry(ordinal: ordinal),
              arm == entry.arm,
              mutationID == entry.mutationID,
              exactAllowedFailedLegIDSets
                == entry.exactAllowedFailedLegIDSets
        else {
            throw PrimeNativeNeuralGateCorrectedMutationRecordContractError
                .invalidMutationIdentity
        }
        self.arm = arm
        self.ordinal = ordinal
        self.mutationID = mutationID
        self.exactAllowedFailedLegIDSets =
            exactAllowedFailedLegIDSets
    }

    private enum CodingKeys: String, CodingKey {
        case arm
        case ordinal
        case mutationID = "mutation_id"
        case exactAllowedFailedLegIDSets =
            "exact_allowed_failed_leg_id_sets"
    }
}

public struct PrimeNativeNeuralGateCorrectedMutationRecordContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let surfaceContractID: String
    public let surfaceSerializationContractID: String
    public let correctedArm: PrimeNativeNeuralGateArtifactArm
    public let orderedControlLegIDs:
        [PrimeNativeNeuralGateCorrectedControlLegID]
    public let orderedMutationCatalog:
        [PrimeNativeNeuralGateCorrectedMutationCatalogEntry]
    public let commonAndBranchReferencesAreCopiedNonAuthorizingValues:
        Bool
    public let mutationTransformationOwnedBySharedTarget: Bool
    public let detectorClassificationOwnedBySharedTarget: Bool

    public static let frozenV1: Self = {
        Self(
            schemaVersion: 1,
            contractID:
                "prime_stage_b_corrected_mutation_control_surface_contract_v1",
            surfaceContractID:
                PrimeNativeNeuralGateCorrectedMutationSurfaceContract
                .contractID,
            surfaceSerializationContractID:
                PrimeNativeNeuralGateCorrectedMutationSurfaceContract
                .serializationContractID,
            correctedArm: .correctedFixedCapEOS,
            orderedControlLegIDs:
                PrimeNativeNeuralGateCorrectedControlLegID.allCases,
            orderedMutationCatalog:
                PrimeNativeNeuralGateCorrectedMutationCaseID
                .allCases.enumerated().map {
                    PrimeNativeNeuralGateCorrectedMutationCatalogEntry(
                        ordinal: UInt32($0.offset + 1),
                        mutationID: $0.element
                    )
                },
            commonAndBranchReferencesAreCopiedNonAuthorizingValues:
                true,
            mutationTransformationOwnedBySharedTarget: false,
            detectorClassificationOwnedBySharedTarget: false
        )
    }()

    public func entry(
        ordinal: UInt32
    ) -> PrimeNativeNeuralGateCorrectedMutationCatalogEntry? {
        guard ordinal >= 1 else {
            return nil
        }
        let index = Int(ordinal - 1)
        guard orderedMutationCatalog.indices.contains(index) else {
            return nil
        }
        return orderedMutationCatalog[index]
    }

    public func entry(
        mutationID:
            PrimeNativeNeuralGateCorrectedMutationCaseID
    ) -> PrimeNativeNeuralGateCorrectedMutationCatalogEntry? {
        orderedMutationCatalog.first {
            $0.mutationID == mutationID
        }
    }

    public func identity(
        mutationID:
            PrimeNativeNeuralGateCorrectedMutationCaseID
    ) throws -> PrimeNativeNeuralGateCorrectedMutationIdentity {
        guard let entry = entry(mutationID: mutationID) else {
            throw PrimeNativeNeuralGateCorrectedMutationRecordContractError
                .invalidMutationIdentity
        }
        return try PrimeNativeNeuralGateCorrectedMutationIdentity(
            arm: entry.arm,
            ordinal: entry.ordinal,
            mutationID: entry.mutationID,
            exactAllowedFailedLegIDSets:
                entry.exactAllowedFailedLegIDSets
        )
    }

    public func validate() throws {
        let importedCatalog =
            PrimeNativeNeuralGateMutationCatalog.correctedEntries
        guard self == .frozenV1,
              schemaVersion == 1,
              contractID
                == "prime_stage_b_corrected_mutation_control_surface_contract_v1",
              surfaceContractID
                == PrimeNativeNeuralGateCorrectedMutationSurfaceContract
                .contractID,
              contractID != surfaceContractID,
              surfaceSerializationContractID
                == PrimeNativeNeuralGateCorrectedMutationSurfaceContract
                .serializationContractID,
              correctedArm == .correctedFixedCapEOS,
              orderedControlLegIDs
                == PrimeNativeNeuralGateCorrectedControlLegID.allCases,
              orderedControlLegIDs.map(\.rawValue)
                == PrimeNativeNeuralGateReplayLegDomain
                .correctedMutationFailureLegIDs,
              orderedMutationCatalog.count == 15,
              importedCatalog.count == orderedMutationCatalog.count,
              commonAndBranchReferencesAreCopiedNonAuthorizingValues,
              !mutationTransformationOwnedBySharedTarget,
              !detectorClassificationOwnedBySharedTarget
        else {
            throw PrimeNativeNeuralGateCorrectedMutationRecordContractError
                .invalidFrozenContract
        }
        for (index, pair) in zip(
            orderedMutationCatalog,
            importedCatalog
        ).enumerated() {
            let local = pair.0
            let imported = pair.1
            guard local.arm == .correctedFixedCapEOS,
                  local.ordinal == UInt32(index + 1),
                  local.ordinal == imported.ordinal,
                  local.mutationID.rawValue == imported.mutationID,
                  local.exactAllowedFailedLegIDSets
                    == [[local.mutationID.expectedFailedLegID]],
                  local.mutationID.expectedFailedLegID.rawValue
                    == imported.expectedFailedLegID
            else {
                throw PrimeNativeNeuralGateCorrectedMutationRecordContractError
                    .invalidFrozenContract
            }
        }
    }

    public func contentSHA256() throws -> String {
        try validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        return PrimeNativeNeuralGateInvariantCodec.sha256(
            try encoder.encode(self)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case surfaceContractID = "surface_contract_id"
        case surfaceSerializationContractID =
            "surface_serialization_contract_id"
        case correctedArm = "corrected_arm"
        case orderedControlLegIDs = "ordered_control_leg_ids"
        case orderedMutationCatalog = "ordered_mutation_catalog"
        case commonAndBranchReferencesAreCopiedNonAuthorizingValues =
            "common_and_branch_references_are_copied_non_authorizing_values"
        case mutationTransformationOwnedBySharedTarget =
            "mutation_transformation_owned_by_shared_target"
        case detectorClassificationOwnedBySharedTarget =
            "detector_classification_owned_by_shared_target"
    }
}
