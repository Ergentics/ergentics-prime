import Foundation
import PrimeCore
import PrimeNativeNeuralGateCorrectedFixtureAuthority
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateReplayCaptureInventory
import PrimeNativeNeuralGateReplayComposition
import PrimeNativeNeuralGateReplaySourceComposition
import PrimeNativeNeuralGateReplayTransport

public enum PrimeNativeNeuralGatePromptTargetCrosswalkAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case capturedSourceRequired
    case fixtureAuthorityRejected
    case invalidCrosswalkCardinality
    case crosswalkIdentityMismatch
    case duplicateExecutionIndex
    case duplicateSourceRowOrdinal
    case invalidSourceRowOrdinal
    case duplicatePromptBinding
    case missingScheduledPrompt
    case promptBindingMismatch
    case missingOuterEvaluation
    case correlationMismatch
    case expectedCompletionMismatch
    case eosBindingMismatch
    case invalidTypedBinding
    case replayJoinRejected
    case sourceChangedDuringAuthorityJoin
}

/// Frozen contract for the deliberately trap-bearing source-derived
/// prompt/target authority boundary.
public struct PrimeNativeNeuralGatePromptTargetCrosswalkAuthorityContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let captureContractID: String
    public let fixtureIdentitySHA256: String
    public let sourceDerivedCrosswalkIdentitySHA256:
        String
    public let orderedPromptBindingsSHA256: String
    public let orderedTargetBindingsSHA256: String
    public let promptBindingDomain: String
    public let correlationBindingDomain: String
    public let targetBindingDomain: String
    public let exactRowCount: Int
    public let independentSourceDerivationRequired: Bool
    public let keyedNonpositionalJoinRequired: Bool
    public let exactTerminalEOSRequired: Bool
    public let correctedFixtureIdentityEstablished: Bool
    public let independentPromptTargetCrosswalkEstablished: Bool
    public let outerExpectedCompletionBindingEstablished: Bool
    public let durableArtifactOriginRequired: Bool
    public let promptContentTargetIndependenceEstablished: Bool
    public let processDeliveryObserved: Bool
    public let modelExecutionEstablished: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        contractID:
            "prime_stage_b_independent_source_derived_prompt_target_crosswalk_authority_v1",
        captureContractID:
            PrimeNativeNeuralGateReplayCaptureInventoryContract
            .frozenV1.contractID,
        fixtureIdentitySHA256:
            PrimeNativeNeuralGateCorrectedFixtureObservation
            .frozenFixtureIdentitySHA256,
        sourceDerivedCrosswalkIdentitySHA256:
            PrimeNativeNeuralGateCorrectedFixtureObservation
            .frozenCrosswalkIdentitySHA256,
        orderedPromptBindingsSHA256:
            PrimeNativeNeuralGateCorrectedFixtureObservation
            .frozenOrderedPromptOnlyInputBindingsSHA256,
        orderedTargetBindingsSHA256:
            PrimeNativeNeuralGateCorrectedFixtureObservation
            .frozenOrderedTargetTokenBindingsSHA256,
        promptBindingDomain: "PRIMECPI2",
        correlationBindingDomain: "PRIMECOR1",
        targetBindingDomain: "PRIMECFT1",
        exactRowCount:
            PrimeNativeNeuralGateCorrectedFixtureObservation
            .exactRowCount,
        independentSourceDerivationRequired: true,
        keyedNonpositionalJoinRequired: true,
        exactTerminalEOSRequired: true,
        correctedFixtureIdentityEstablished: true,
        independentPromptTargetCrosswalkEstablished: true,
        outerExpectedCompletionBindingEstablished: true,
        durableArtifactOriginRequired: true,
        promptContentTargetIndependenceEstablished: false,
        processDeliveryObserved: false,
        modelExecutionEstablished: false,
        mechanicsPassAuthorized: false,
        terminalReceiptAuthorized: false,
        scientificAuthorityAuthorized: false,
        productAuthorityAuthorized: false,
        authorityStatement:
            "This V1 trap-bearing authority derives the exact 18,432 source prompt/target associations through the frozen corrected-fixture authority, preserving typed PRIMECPI2 prompt, PRIMECOR1 correlation, and PRIMECFT1 target-plus-EOS domains. It consumes only a sealed single-epoch four-source capture, reconstructs the source schedule, joins by unique execution index and typed prompt binding rather than array position or row ID, and requires exact outer expected-completion bytes. The default path revalidates the retained source inventory before independent fixture derivation, again before association and join, and after the join. The sealed pre-derived overload revalidates before and after association and join because its immutable fixture authority is capture-independent. Success establishes corrected fixture identity, the independent prompt/target crosswalk, outer expected-completion binding, and durable origin for the captured bytes. It does not prove the raw process was target-blind, observe delivery or model execution, authorize mechanics PASS, issue a receipt, make a scientific claim, or authorize product use."
    )

    public func validate() throws {
        guard self == .frozenV1,
              schemaVersion == 1,
              captureContractID
                == PrimeNativeNeuralGateReplayCaptureInventoryContract
                .frozenV1.contractID,
              fixtureIdentitySHA256
                == PrimeNativeNeuralGateCorrectedFixtureObservation
                .frozenFixtureIdentitySHA256,
              sourceDerivedCrosswalkIdentitySHA256
                == PrimeNativeNeuralGateCorrectedFixtureObservation
                .frozenCrosswalkIdentitySHA256,
              orderedPromptBindingsSHA256
                == PrimeNativeNeuralGateCorrectedFixtureObservation
                .frozenOrderedPromptOnlyInputBindingsSHA256,
              orderedTargetBindingsSHA256
                == PrimeNativeNeuralGateCorrectedFixtureObservation
                .frozenOrderedTargetTokenBindingsSHA256,
              promptBindingDomain == "PRIMECPI2",
              correlationBindingDomain == "PRIMECOR1",
              targetBindingDomain == "PRIMECFT1",
              exactRowCount
                == PrimeNativeNeuralGateCorrectedFixtureObservation
                .exactRowCount,
              independentSourceDerivationRequired,
              keyedNonpositionalJoinRequired,
              exactTerminalEOSRequired,
              correctedFixtureIdentityEstablished,
              independentPromptTargetCrosswalkEstablished,
              outerExpectedCompletionBindingEstablished,
              durableArtifactOriginRequired,
              !promptContentTargetIndependenceEstablished,
              !processDeliveryObserved,
              !modelExecutionEstablished,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGatePromptTargetCrosswalkAuthorityError
                .invalidFrozenContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case captureContractID = "capture_contract_id"
        case fixtureIdentitySHA256 =
            "fixture_identity_sha256"
        case sourceDerivedCrosswalkIdentitySHA256 =
            "source_derived_crosswalk_identity_sha256"
        case orderedPromptBindingsSHA256 =
            "ordered_prompt_bindings_sha256"
        case orderedTargetBindingsSHA256 =
            "ordered_target_bindings_sha256"
        case promptBindingDomain =
            "prompt_binding_domain"
        case correlationBindingDomain =
            "correlation_binding_domain"
        case targetBindingDomain = "target_binding_domain"
        case exactRowCount = "exact_row_count"
        case independentSourceDerivationRequired =
            "independent_source_derivation_required"
        case keyedNonpositionalJoinRequired =
            "keyed_nonpositional_join_required"
        case exactTerminalEOSRequired =
            "exact_terminal_eos_required"
        case correctedFixtureIdentityEstablished =
            "corrected_fixture_identity_established"
        case independentPromptTargetCrosswalkEstablished =
            "independent_prompt_target_crosswalk_established"
        case outerExpectedCompletionBindingEstablished =
            "outer_expected_completion_binding_established"
        case durableArtifactOriginRequired =
            "durable_artifact_origin_required"
        case promptContentTargetIndependenceEstablished =
            "prompt_content_target_independence_established"
        case processDeliveryObserved =
            "process_delivery_observed"
        case modelExecutionEstablished =
            "model_execution_established"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
        case authorityStatement = "authority_statement"
    }
}

/// Sealed result of the durable source join and independent crosswalk.
public struct PrimeNativeNeuralGateCrosswalkBoundReplay:
    @unchecked Sendable
{
    public let contractID: String
    public let captureIdentitySHA256: String
    public let crosswalkIdentitySHA256: String
    public let fixtureIdentitySHA256: String
    public let sourceBoundReplay:
        PrimeNativeNeuralGateSourceBoundJoinedReplayReplicate
    public let crosswalk:
        PrimeNativeNeuralGateSourceDerivedPromptTargetCrosswalk

    public let exactSourceCapabilityJoinObserved = true
    public let singleSourceCaptureEpochEstablished = true
    public let durableArtifactOriginEstablished = true
    public let correctedFixtureIdentityEstablished = true
    public let independentPromptTargetCrosswalkEstablished = true
    public let outerExpectedCompletionBindingEstablished = true
    public let promptContentTargetIndependenceEstablished = false
    public let processDeliveryObserved = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    private let capturedSource:
        PrimeNativeNeuralGateFourSourceCaptureInventory

    fileprivate init(
        capturedSource:
            PrimeNativeNeuralGateFourSourceCaptureInventory,
        sourceBoundReplay:
            PrimeNativeNeuralGateSourceBoundJoinedReplayReplicate,
        crosswalk:
            PrimeNativeNeuralGateSourceDerivedPromptTargetCrosswalk
    ) {
        contractID =
            PrimeNativeNeuralGatePromptTargetCrosswalkAuthorityContract
            .frozenV1.contractID
        captureIdentitySHA256 =
            capturedSource.captureIdentitySHA256
        crosswalkIdentitySHA256 =
            crosswalk.crosswalkIdentitySHA256
        fixtureIdentitySHA256 =
            crosswalk.fixtureIdentitySHA256
        self.capturedSource = capturedSource
        self.sourceBoundReplay = sourceBoundReplay
        self.crosswalk = crosswalk
    }

    @discardableResult
    public func validateSourceStillUnchanged() throws
        -> PrimeNativeNeuralGateRealizedFilesystemInventory
    {
        try capturedSource.validateStillUnchanged()
    }
}

public enum PrimeNativeNeuralGatePromptTargetCrosswalkAuthority {
    private typealias Error =
        PrimeNativeNeuralGatePromptTargetCrosswalkAuthorityError

    public static func bind(
        capturedSource:
            PrimeNativeNeuralGateFourSourceCaptureInventory
    ) throws -> PrimeNativeNeuralGateCrosswalkBoundReplay {
        do {
            _ = try capturedSource.validateStillUnchanged()
        } catch {
            throw Error.sourceChangedDuringAuthorityJoin
        }
        let crosswalk:
            PrimeNativeNeuralGateSourceDerivedPromptTargetCrosswalk
        do {
            crosswalk = try
                PrimeNativeNeuralGateCorrectedFixtureObservation
                .derivePromptTargetCrosswalk()
        } catch {
            throw Error.fixtureAuthorityRejected
        }
        return try bind(
            capturedSource: capturedSource,
            sourceDerivedCrosswalk: crosswalk
        )
    }

    /// Accepts only the sealed, non-Codable capability issued by the frozen
    /// fixture authority. This overload permits one source derivation to be
    /// reused across independently captured replicate roots without admitting
    /// caller-authored prompt/target rows. The crosswalk is independent of a
    /// capture root; this overload brackets association and join, not the
    /// earlier source-only derivation, with retained-inventory recaptures.
    public static func bind(
        capturedSource:
            PrimeNativeNeuralGateFourSourceCaptureInventory,
        sourceDerivedCrosswalk crosswalk:
            PrimeNativeNeuralGateSourceDerivedPromptTargetCrosswalk
    ) throws -> PrimeNativeNeuralGateCrosswalkBoundReplay {
        let contract =
            PrimeNativeNeuralGatePromptTargetCrosswalkAuthorityContract
            .frozenV1
        try contract.validate()
        guard capturedSource.contractID
                == contract.captureContractID,
              capturedSource.exactWholeRootNodeClosureEstablished,
              capturedSource.singleSourceCaptureEpochEstablished,
              capturedSource.durableArtifactOriginEstablished,
              !capturedSource
                .independentPromptTargetCrosswalkEstablished,
              !capturedSource
                .promptContentTargetIndependenceEstablished,
              !capturedSource.processDeliveryObserved,
              !capturedSource.modelExecutionEstablished,
              !capturedSource.mechanicsPassAuthorized
        else {
            throw Error.capturedSourceRequired
        }
        do {
            _ = try capturedSource.validateStillUnchanged()
        } catch {
            throw Error.sourceChangedDuringAuthorityJoin
        }

        guard crosswalk.fixtureIdentitySHA256
                == contract.fixtureIdentitySHA256,
              crosswalk.crosswalkIdentitySHA256
                == contract
                .sourceDerivedCrosswalkIdentitySHA256,
              crosswalk.orderedPromptBindingsSHA256
                == contract.orderedPromptBindingsSHA256,
              crosswalk.orderedTargetBindingsSHA256
                == contract.orderedTargetBindingsSHA256,
              crosswalk.entries.count == contract.exactRowCount,
              crosswalk.sourceDerivedFixtureIdentityEstablished,
              crosswalk.independentPromptTargetMaterialDerived,
              !crosswalk
                .promptContentTargetIndependenceEstablished,
              !crosswalk.modelExecutionEstablished,
              !crosswalk.mechanicsPassAuthorized
        else {
            throw Error.crosswalkIdentityMismatch
        }

        let schedule:
            PrimeNativeNeuralGateSourceBoundPromptSchedule
        let joined:
            PrimeNativeNeuralGateSourceBoundJoinedReplayReplicate
        do {
            schedule = try
                PrimeNativeNeuralGateReplaySourceComposition
                .makePromptSchedule(
                    promptRecords:
                        capturedSource.promptRecords
                )
            joined = try
                PrimeNativeNeuralGateReplaySourceComposition
                .join(
                    schedule: schedule,
                    outerRecords:
                        capturedSource.outerRecords,
                    rawRecords:
                        capturedSource.rawRecords,
                    logitSidecar:
                        capturedSource.logitSidecar
                )
        } catch {
            throw Error.replayJoinRejected
        }
        try validateAssociation(
            crosswalk: crosswalk,
            schedule: schedule,
            outerRecords:
                capturedSource.outerRecords.records
        )
        guard joined.rootIdentity
                == capturedSource.rootIdentity,
              joined.joinedReplay.orderedRows.count
                == contract.exactRowCount,
              joined.exactSourceCapabilityJoinObserved,
              !joined.durableArtifactOriginEstablished,
              !joined
                .independentPromptTargetCrosswalkEstablished,
              !joined
                .outerExpectedCompletionBindingEstablished,
              !joined.modelExecutionEstablished,
              !joined.mechanicsPassAuthorized
        else {
            throw Error.replayJoinRejected
        }
        do {
            _ = try capturedSource.validateStillUnchanged()
        } catch {
            throw Error.sourceChangedDuringAuthorityJoin
        }
        return PrimeNativeNeuralGateCrosswalkBoundReplay(
            capturedSource: capturedSource,
            sourceBoundReplay: joined,
            crosswalk: crosswalk
        )
    }

    private static func validateAssociation(
        crosswalk:
            PrimeNativeNeuralGateSourceDerivedPromptTargetCrosswalk,
        schedule:
            PrimeNativeNeuralGateSourceBoundPromptSchedule,
        outerRecords:
            [PrimeNativeNeuralGateReplayOuterEvaluationRow]
    ) throws {
        let expectedCount =
            PrimeNativeNeuralGatePromptTargetCrosswalkAuthorityContract
            .frozenV1.exactRowCount
        guard crosswalk.entries.count == expectedCount,
              schedule.schedule.orderedPrompts.count
                == expectedCount,
              outerRecords.count == expectedCount
        else {
            throw Error.invalidCrosswalkCardinality
        }

        var scheduledByPromptBinding =
            [String: PrimeNativeNeuralGateScheduledPrompt]()
        for scheduled in schedule.schedule.orderedPrompts {
            let binding =
                scheduled.primeCPI2PromptBindingSHA256
            guard scheduledByPromptBinding[binding] == nil
            else {
                throw Error.duplicatePromptBinding
            }
            scheduledByPromptBinding[binding] =
                scheduled
        }
        var outerByIndex =
            [UInt32: PrimeNativeNeuralGateReplayOuterEvaluationRow]()
        for outer in outerRecords {
            guard outerByIndex[outer.executionIndex] == nil
            else {
                throw Error.duplicateExecutionIndex
            }
            outerByIndex[outer.executionIndex] = outer
        }
        var observedSourceOrdinals = Set<UInt32>()
        var observedPromptBindings = Set<String>()
        let eos = UInt16(
            PrimeNativeNeuralGateCorrectedExecutionPolicy
            .endOfSequenceTokenID
        )

        for entry in crosswalk.entries {
            guard entry.sourceRowOrdinal
                    < UInt32(expectedCount)
            else {
                throw Error.invalidSourceRowOrdinal
            }
            guard observedSourceOrdinals.insert(
                    entry.sourceRowOrdinal
                  ).inserted
            else {
                throw Error.duplicateSourceRowOrdinal
            }
            guard observedPromptBindings.insert(
                    entry.promptBinding.sha256
                  ).inserted
            else {
                throw Error.duplicatePromptBinding
            }
            guard let scheduled = scheduledByPromptBinding[
                    entry.promptBinding.sha256
                  ]
            else {
                throw Error.missingScheduledPrompt
            }
            let promptInput:
                PrimeNativeNeuralGatePromptOnlyExecutionInput
            do {
                promptInput = try
                    PrimeNativeNeuralGatePromptOnlyExecutionInput
                    .derive(
                        promptText:
                            scheduled.promptRow.canonicalPrompt
                    )
            } catch {
                throw Error.promptBindingMismatch
            }
            guard scheduled.promptRow.canonicalPrompt
                    == entry.canonicalPrompt,
                  scheduled.promptRow.promptTokenIDs
                    == entry.promptTokenIDs,
                  promptInput.bindingSHA256
                    == entry.promptBinding.sha256,
                  scheduled
                    .primeCPI2PromptBindingSHA256
                    == entry.promptBinding.sha256
            else {
                throw Error.promptBindingMismatch
            }
            guard let outer = outerByIndex[
                    scheduled.executionIndex
                  ]
            else {
                throw Error.missingOuterEvaluation
            }
            guard outer.correlationID
                    == scheduled.correlationID
            else {
                throw Error.correlationMismatch
            }
            guard outer.expectedCompletionUTF8
                    == entry.expectedCompletionUTF8,
                  outer.canonicalExpectedCompletion
                    == entry.canonicalExpectedCompletion,
                  Data(
                    outer.canonicalExpectedCompletion.utf8
                  ) == entry.expectedCompletionUTF8
            else {
                throw Error.expectedCompletionMismatch
            }
            let expectedTargetTokens =
                Array(entry.expectedCompletionUTF8).map {
                    UInt16($0)
                    + UInt16(
                        PrimeNativeNeuralGateCorrectedExecutionPolicy
                        .byteTokenBase
                    )
                } + [eos]
            guard entry.targetTokenIDsWithEOS
                    == expectedTargetTokens,
                  entry.targetTokenIDsWithEOS.last == eos,
                  !entry.targetTokenIDsWithEOS
                    .dropLast().contains(eos)
            else {
                throw Error.eosBindingMismatch
            }
            guard isLowercaseSHA256(
                    entry.promptBinding.sha256
                  ),
                  isLowercaseSHA256(
                    entry.targetBinding.sha256
                  )
            else {
                throw Error.invalidTypedBinding
            }
        }
        guard observedSourceOrdinals.count == expectedCount,
              observedPromptBindings.count == expectedCount,
              scheduledByPromptBinding.count == expectedCount,
              outerByIndex.count == expectedCount
        else {
            throw Error.invalidCrosswalkCardinality
        }
    }

    private static func isLowercaseSHA256(
        _ value: String
    ) -> Bool {
        guard value.utf8.count == 64 else {
            return false
        }
        return value.utf8.allSatisfy { byte in
            (48 ... 57).contains(byte)
                || (97 ... 102).contains(byte)
        }
    }
}
