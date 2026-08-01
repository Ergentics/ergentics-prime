import Foundation
import PrimeNativeNeuralGateReplayMechanics

public enum PrimeNativeNeuralGateHistoricalObservationSeamError:
    Error,
    Equatable,
    Sendable
{
    case invalidCriticalLegs
    case invalidHistoricalOutcome
    case invalidTriadicLabel
    case invalidFingerprint
    case invalidMutationSweep
    case invalidComponent(String)
    case invalidNextAction
    case invalidAuthorityBoundary
}

public enum PrimeNativeNeuralGateHistoricalObservationAvailability:
    String,
    Encodable,
    Equatable,
    Sendable
{
    case notExposedByPinnedGatePublicAPI =
        "not_exposed_by_pinned_gate_public_api"
    case notObservedByObservationSeam =
        "not_observed_by_observation_seam"
}

public struct PrimeNativeNeuralGateHistoricalCriticalLegProjection:
    Encodable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let legID: String
    public let passed: Bool
    public let detail: String
    public let historicalIndependentLabel: Bool

    fileprivate init(
        ordinal: Int,
        witness: PrimeNeuralVerifyAbstainGate.Witness
    ) {
        self.ordinal = ordinal
        legID = witness.leg
        passed = witness.pass
        detail = witness.detail
        historicalIndependentLabel = witness.independent
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case legID = "leg_id"
        case passed
        case detail
        case historicalIndependentLabel =
            "historical_independent_label"
    }
}

public struct PrimeNativeNeuralGateHistoricalFingerprintProjection:
    Encodable,
    Equatable,
    Sendable
{
    public let prime: UInt64
    public let evaluationPoints: [UInt64]
    public let residues: [UInt64]
    public let recordCount: Int

    fileprivate init(
        _ fingerprint:
            PrimeNeuralNativeLanguageVerifyAbstainGate
            .FiniteFieldFingerprint
    ) {
        prime = fingerprint.prime
        evaluationPoints = fingerprint.evaluationPoints
        residues = fingerprint.residues
        recordCount = fingerprint.recordCount
    }

    fileprivate func validate() throws {
        guard prime == 2_147_483_647,
              evaluationPoints == [257, 65_537, 1_000_003],
              residues.count == evaluationPoints.count,
              residues.allSatisfy({ $0 < prime }),
              recordCount == 59_497
        else {
            throw PrimeNativeNeuralGateHistoricalObservationSeamError
                .invalidFingerprint
        }
    }

    private enum CodingKeys: String, CodingKey {
        case prime
        case evaluationPoints = "evaluation_points"
        case residues
        case recordCount = "record_count"
    }
}

public struct PrimeNativeNeuralGateHistoricalMutationProjection:
    Encodable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let mutationID: String
    public let expectedFailedLegID: String
    public let historicalDetected: Bool
    public let historicalFingerprintDiverged: Bool
    public let historicalRestored: Bool
    public let historicalRestoredFingerprintExact: Bool

    fileprivate init(
        ordinal: Int,
        result:
            PrimeNeuralNativeLanguageVerifyAbstainGate
            .MutationResult
    ) {
        self.ordinal = ordinal
        mutationID = result.mutation.rawValue
        expectedFailedLegID =
            result.expectedFailedLeg
        historicalDetected = result.detected
        historicalFingerprintDiverged =
            result.fingerprintDiverged
        historicalRestored = result.restored
        historicalRestoredFingerprintExact =
            result.restoredFingerprintExact
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case mutationID = "mutation_id"
        case expectedFailedLegID =
            "expected_failed_leg_id"
        case historicalDetected =
            "historical_detected"
        case historicalFingerprintDiverged =
            "historical_fingerprint_diverged"
        case historicalRestored =
            "historical_restored"
        case historicalRestoredFingerprintExact =
            "historical_restored_fingerprint_exact"
    }
}

public struct PrimeNativeNeuralGateHistoricalMutationSweepProjection:
    Encodable,
    Equatable,
    Sendable
{
    public let historicalOutcome: String
    public let historicalTriadicLabel: String
    public let orderedMutations:
        [PrimeNativeNeuralGateHistoricalMutationProjection]
    public let sameFamilyDetectorOnly: Bool
    public let independentDetectionEstablished: Bool
    public let exactAllowedFailureSetsEstablished: Bool

    fileprivate init(
        _ sweep:
            PrimeNeuralNativeLanguageVerifyAbstainGate
            .MutationSweep
    ) {
        historicalOutcome = sweep.outcome
        historicalTriadicLabel = sweep.triadicVerdict
        orderedMutations = sweep.results.enumerated().map {
            PrimeNativeNeuralGateHistoricalMutationProjection(
                ordinal: $0.offset + 1,
                result: $0.element
            )
        }
        sameFamilyDetectorOnly = true
        independentDetectionEstablished = false
        exactAllowedFailureSetsEstablished = false
    }

    fileprivate func validate() throws {
        let mutations =
            PrimeNeuralNativeLanguageVerifyAbstainGate
            .Mutation.allCases
        let allMutationChecksPass = orderedMutations
            .allSatisfy {
                $0.historicalDetected
                    && $0.historicalFingerprintDiverged
                    && $0.historicalRestored
                    && $0.historicalRestoredFingerprintExact
            }
        let detectedCount = orderedMutations
            .filter(\.historicalDetected).count
        let expectedOutcome = allMutationChecksPass
            ? "GROUNDED" : "ABSTAIN"
        let expectedTriadicLabel = allMutationChecksPass
            ? "independentThreePlus(\(mutations.count))"
            : "oracleDerived(\(detectedCount))"
        guard orderedMutations.count == mutations.count,
              orderedMutations.map(\.ordinal)
                == Array(1 ... mutations.count),
              orderedMutations.map(\.mutationID)
                == mutations.map(\.rawValue),
              orderedMutations.map(\.expectedFailedLegID)
                == mutations.map(\.expectedFailedLeg)
        else {
            throw PrimeNativeNeuralGateHistoricalObservationSeamError
                .invalidMutationSweep
        }
        guard historicalOutcome == expectedOutcome else {
            throw PrimeNativeNeuralGateHistoricalObservationSeamError
                .invalidHistoricalOutcome
        }
        guard historicalTriadicLabel == expectedTriadicLabel else {
            throw PrimeNativeNeuralGateHistoricalObservationSeamError
                .invalidTriadicLabel
        }
        guard
              sameFamilyDetectorOnly,
              !independentDetectionEstablished,
              !exactAllowedFailureSetsEstablished
        else {
            throw PrimeNativeNeuralGateHistoricalObservationSeamError
                .invalidMutationSweep
        }
    }

    private enum CodingKeys: String, CodingKey {
        case historicalOutcome = "historical_outcome"
        case historicalTriadicLabel =
            "historical_triadic_label"
        case orderedMutations = "ordered_mutations"
        case sameFamilyDetectorOnly =
            "same_family_detector_only"
        case independentDetectionEstablished =
            "independent_detection_established"
        case exactAllowedFailureSetsEstablished =
            "exact_allowed_failure_sets_established"
    }
}

public struct PrimeNativeNeuralGateHistoricalNamedBoolean:
    Encodable,
    Equatable,
    Sendable
{
    public let name: String
    public let value: Bool

    fileprivate init(name: String, value: Bool) {
        self.name = name
        self.value = value
    }
}

/// Prime-owned, non-authorizing projection of the exact historical gate's
/// public assessment surface.
///
/// The snapshot preserves historical payload while forcing the Prime
/// admission disposition to ABSTAIN. It cannot establish where the assessment
/// came from, whether a model or gate executed, whether bytes were durably
/// published, whether the same-family mutation dispatch was independently
/// detected, or whether a distinct-family/four-tier audit occurred.
public struct PrimeNativeNeuralGateHistoricalAssessmentSnapshot:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let sourceClosureContractID: String
    public let adaptationProofV3ID: String
    public let sourceMaterialContractID: String
    public let gateSourceSHA256: String
    public let carrierSourceSHA256: String
    public let mutationMaterialSHA256: String
    public let criticalLegs:
        [PrimeNativeNeuralGateHistoricalCriticalLegProjection]
    public let historicalAgreeCount: Int
    public let historicalIndependentPassCount: Int
    public let historicalOutcome: String
    public let historicalTriadicLabel: String
    public let historicalNextAction: String
    public let fingerprint:
        PrimeNativeNeuralGateHistoricalFingerprintProjection?
    public let mutationSweep:
        PrimeNativeNeuralGateHistoricalMutationSweepProjection?
    public let materialReloadComponents:
        [PrimeNativeNeuralGateHistoricalNamedBoolean]
    public let invariantRecordsAvailability:
        PrimeNativeNeuralGateHistoricalObservationAvailability
    public let perMutationFingerprintsAvailability:
        PrimeNativeNeuralGateHistoricalObservationAvailability
    public let observedFailedLegSetsAvailability:
        PrimeNativeNeuralGateHistoricalObservationAvailability
    public let phaseTelemetryAvailability:
        PrimeNativeNeuralGateHistoricalObservationAvailability
    public let primeAdmissionDisposition: String
    public let historicalPayloadOnly: Bool
    public let candidateDeclaredPayloadAuthoritative: Bool
    public let compiledSourceClosureObserved: Bool
    public let gateExecutionEvidenceBound: Bool
    public let modelExecutionEvidenceBound: Bool
    public let durablePublicationObserved: Bool
    public let independentDetectionEstablished: Bool
    public let distinctImplementationFamiliesEstablished: Bool
    public let agentContractKitFourTierAuditPerformed: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    fileprivate init(
        assessment:
            PrimeNeuralNativeLanguageVerifyAbstainGate
            .Assessment
    ) {
        schemaVersion = 1
        schemaID =
            "prime_native_neural_gate_historical_assessment_snapshot_v1"
        sourceClosureContractID =
            PrimeNativeNeuralGateHistoricalObservationSeam
            .sourceClosureContractID
        adaptationProofV3ID =
            PrimeNativeNeuralGateHistoricalObservationSeam
            .adaptationProofV3ID
        sourceMaterialContractID =
            PrimeNativeNeuralGateHistoricalObservationSeam
            .sourceMaterialContractID
        gateSourceSHA256 =
            PrimeNativeNeuralGateHistoricalObservationSeam
            .gateSourceSHA256
        carrierSourceSHA256 =
            PrimeNativeNeuralGateHistoricalObservationSeam
            .carrierSourceSHA256
        mutationMaterialSHA256 =
            PrimeNativeNeuralGateHistoricalObservationSeam
            .mutationMaterialSHA256
        criticalLegs = assessment.verdict.witnesses
            .enumerated().map {
                PrimeNativeNeuralGateHistoricalCriticalLegProjection(
                    ordinal: $0.offset + 1,
                    witness: $0.element
                )
            }
        historicalAgreeCount =
            assessment.verdict.agreeCount
        historicalIndependentPassCount =
            assessment.verdict.independentPassCount
        historicalOutcome = assessment.outcome
        historicalTriadicLabel =
            assessment.triadicVerdict
        historicalNextAction = assessment.nextAction
        fingerprint = assessment.fingerprint.map(
            PrimeNativeNeuralGateHistoricalFingerprintProjection.init
        )
        mutationSweep = assessment.mutationSweep.map(
            PrimeNativeNeuralGateHistoricalMutationSweepProjection.init
        )
        materialReloadComponents =
            assessment.materialReloadComponentPasses
            .map {
                PrimeNativeNeuralGateHistoricalNamedBoolean(
                    name: $0.key,
                    value: $0.value
                )
            }
            .sorted { $0.name < $1.name }
        invariantRecordsAvailability =
            .notExposedByPinnedGatePublicAPI
        perMutationFingerprintsAvailability =
            .notExposedByPinnedGatePublicAPI
        observedFailedLegSetsAvailability =
            .notExposedByPinnedGatePublicAPI
        phaseTelemetryAvailability =
            .notObservedByObservationSeam
        primeAdmissionDisposition = "ABSTAIN"
        historicalPayloadOnly = true
        candidateDeclaredPayloadAuthoritative = false
        compiledSourceClosureObserved = false
        gateExecutionEvidenceBound = false
        modelExecutionEvidenceBound = false
        durablePublicationObserved = false
        independentDetectionEstablished = false
        distinctImplementationFamiliesEstablished = false
        agentContractKitFourTierAuditPerformed = false
        mechanicsPassAuthorized = false
        terminalReceiptAuthorized = false
        sourceBindingV7Issued = false
        scientificAuthorityAuthorized = false
        productAuthorityAuthorized = false
    }

    public func validate() throws {
        let expectedLegIDs =
            PrimeNeuralNativeLanguageVerifyAbstainGate
            .criticalLegIDs
        let expectedAgreeCount = criticalLegs
            .filter(\.passed).count
        let expectedIndependentPassCount = criticalLegs
            .filter {
                $0.passed
                    && $0.historicalIndependentLabel
            }.count
        let expectedTriadicLabel =
            expectedIndependentPassCount
                >= PrimeNeuralVerifyAbstainGate
                .minIndependentWitnesses
            ? "independentThreePlus(\(expectedIndependentPassCount))"
            : "oracleDerived(\(expectedIndependentPassCount))"
        let expectedOutcome = criticalLegs
            .allSatisfy(\.passed)
            ? "GROUNDED" : "ABSTAIN"

        guard schemaVersion == 1,
              schemaID
                == "prime_native_neural_gate_historical_assessment_snapshot_v1",
              sourceClosureContractID
                == PrimeNativeNeuralGateHistoricalObservationSeam
                .sourceClosureContractID,
              adaptationProofV3ID
                == PrimeNativeNeuralGateHistoricalObservationSeam
                .adaptationProofV3ID,
              sourceMaterialContractID
                == PrimeNativeNeuralGateHistoricalObservationSeam
                .sourceMaterialContractID,
              gateSourceSHA256
                == PrimeNativeNeuralGateHistoricalObservationSeam
                .gateSourceSHA256,
              carrierSourceSHA256
                == PrimeNativeNeuralGateHistoricalObservationSeam
                .carrierSourceSHA256,
              mutationMaterialSHA256
                == PrimeNativeNeuralGateHistoricalObservationSeam
                .mutationMaterialSHA256,
              criticalLegs.count == expectedLegIDs.count,
              criticalLegs.map(\.ordinal)
                == Array(1 ... expectedLegIDs.count),
              criticalLegs.map(\.legID)
                == expectedLegIDs,
              historicalAgreeCount == expectedAgreeCount,
              historicalIndependentPassCount
                == expectedIndependentPassCount,
              historicalTriadicLabel == expectedTriadicLabel,
              historicalOutcome == expectedOutcome
        else {
            throw PrimeNativeNeuralGateHistoricalObservationSeamError
                .invalidCriticalLegs
        }

        guard !historicalNextAction.isEmpty,
              historicalNextAction.utf8.count <= 1_024,
              !historicalNextAction.contains("\0")
        else {
            throw PrimeNativeNeuralGateHistoricalObservationSeamError
                .invalidNextAction
        }
        try fingerprint?.validate()
        try mutationSweep?.validate()
        let preMutationLegsPassed = criticalLegs
            .dropLast().allSatisfy(\.passed)
        let mutationLegPassed = criticalLegs.last?.passed
            == true
        guard (mutationSweep != nil) == preMutationLegsPassed else {
            throw PrimeNativeNeuralGateHistoricalObservationSeamError
                .invalidMutationSweep
        }
        guard !criticalLegs[1].passed || fingerprint != nil else {
            throw PrimeNativeNeuralGateHistoricalObservationSeamError
                .invalidFingerprint
        }
        guard mutationLegPassed
                == (mutationSweep?.historicalOutcome
                    == "GROUNDED")
        else {
            throw PrimeNativeNeuralGateHistoricalObservationSeamError
                .invalidMutationSweep
        }
        let expectedMaterialReloadComponentNames = [
            "authority_n1_n5",
            "corpus_report_binding",
            "evaluation_shards",
            "probe_token_manifests",
            "provenance_artifacts",
            "report_codable_replay",
            "report_sha_recommendation_binding",
            "schema_and_material_presence",
            "tokenizer_corpus_verify",
        ]
        let materialReloadPassed =
            !materialReloadComponents.isEmpty
                && materialReloadComponents
                    .allSatisfy(\.value)
        guard materialReloadComponents.map(\.name)
                == expectedMaterialReloadComponentNames,
              Set(materialReloadComponents.map(\.name)).count
                == materialReloadComponents.count,
              criticalLegs.first?.passed
                == materialReloadPassed
        else {
            throw PrimeNativeNeuralGateHistoricalObservationSeamError
                .invalidComponent(
                    "exact_historical_component_set_or_nl1_binding"
                )
        }
        for component in materialReloadComponents {
            guard !component.name.isEmpty,
                  component.name.utf8.count <= 192,
                  component.name.utf8.allSatisfy({
                      ($0 >= 97 && $0 <= 122)
                          || ($0 >= 48 && $0 <= 57)
                          || $0 == 95
                  })
            else {
                throw PrimeNativeNeuralGateHistoricalObservationSeamError
                    .invalidComponent(component.name)
            }
        }
        guard primeAdmissionDisposition == "ABSTAIN",
              historicalPayloadOnly,
              invariantRecordsAvailability
                == .notExposedByPinnedGatePublicAPI,
              perMutationFingerprintsAvailability
                == .notExposedByPinnedGatePublicAPI,
              observedFailedLegSetsAvailability
                == .notExposedByPinnedGatePublicAPI,
              phaseTelemetryAvailability
                == .notObservedByObservationSeam,
              !candidateDeclaredPayloadAuthoritative,
              !compiledSourceClosureObserved,
              !gateExecutionEvidenceBound,
              !modelExecutionEvidenceBound,
              !durablePublicationObserved,
              !independentDetectionEstablished,
              !distinctImplementationFamiliesEstablished,
              !agentContractKitFourTierAuditPerformed,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateHistoricalObservationSeamError
                .invalidAuthorityBoundary
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case sourceClosureContractID =
            "source_closure_contract_id"
        case adaptationProofV3ID =
            "adaptation_proof_v3_id"
        case sourceMaterialContractID =
            "source_material_contract_id"
        case gateSourceSHA256 = "gate_source_sha256"
        case carrierSourceSHA256 =
            "carrier_source_sha256"
        case mutationMaterialSHA256 =
            "mutation_material_sha256"
        case criticalLegs = "critical_legs"
        case historicalAgreeCount =
            "historical_agree_count"
        case historicalIndependentPassCount =
            "historical_independent_pass_count"
        case historicalOutcome = "historical_outcome"
        case historicalTriadicLabel =
            "historical_triadic_label"
        case historicalNextAction =
            "historical_next_action"
        case fingerprint
        case mutationSweep = "mutation_sweep"
        case materialReloadComponents =
            "material_reload_components"
        case invariantRecordsAvailability =
            "invariant_records_availability"
        case perMutationFingerprintsAvailability =
            "per_mutation_fingerprints_availability"
        case observedFailedLegSetsAvailability =
            "observed_failed_leg_sets_availability"
        case phaseTelemetryAvailability =
            "phase_telemetry_availability"
        case primeAdmissionDisposition =
            "prime_admission_disposition"
        case historicalPayloadOnly =
            "historical_payload_only"
        case candidateDeclaredPayloadAuthoritative =
            "candidate_declared_payload_authoritative"
        case compiledSourceClosureObserved =
            "compiled_source_closure_observed"
        case gateExecutionEvidenceBound =
            "gate_execution_evidence_bound"
        case modelExecutionEvidenceBound =
            "model_execution_evidence_bound"
        case durablePublicationObserved =
            "durable_publication_observed"
        case independentDetectionEstablished =
            "independent_detection_established"
        case distinctImplementationFamiliesEstablished =
            "distinct_implementation_families_established"
        case agentContractKitFourTierAuditPerformed =
            "agent_contract_kit_four_tier_audit_performed"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
        case sourceBindingV7Issued =
            "source_binding_v7_issued"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
    }
}

public enum PrimeNativeNeuralGateHistoricalObservationSeam {
    public static let sourceClosureContractID =
        "prime_source_bound_historical_replay_mechanics_contract_v1"
    public static let adaptationProofV3ID =
        "prime_source_pinned_neural_gate_adaptation_proof_v3"
    public static let sourceMaterialContractID =
        "prime_source_pinned_historical_gate_carrier_and_mutation_material_v1"
    public static let gateSourceSHA256 =
        "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6"
    public static let carrierSourceSHA256 =
        "4d9847738c6e3079d8951a3ade21355d6d5be56c193b98a6151b634930e2e51f"
    public static let mutationMaterialSHA256 =
        "307c79edcaa72ee35aa3e0cdad67208c248f27ade898e503834309d3dcd2a8bb"

    public static func observe(
        _ materials:
            PrimeNeuralNativeLanguageVerifyAbstainGate
            .Materials
    ) throws -> PrimeNativeNeuralGateHistoricalAssessmentSnapshot {
        try project(
            PrimeNeuralNativeLanguageVerifyAbstainGate
                .dispose(materials)
        )
    }

    static func project(
        _ assessment:
            PrimeNeuralNativeLanguageVerifyAbstainGate
            .Assessment
    ) throws -> PrimeNativeNeuralGateHistoricalAssessmentSnapshot {
        let snapshot =
            PrimeNativeNeuralGateHistoricalAssessmentSnapshot(
                assessment: assessment
            )
        try snapshot.validate()
        return snapshot
    }

    public static func canonicalBytes(
        of snapshot:
            PrimeNativeNeuralGateHistoricalAssessmentSnapshot
    ) throws -> Data {
        try snapshot.validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        return try encoder.encode(snapshot)
    }

    public static func canonicalSHA256(
        of snapshot:
            PrimeNativeNeuralGateHistoricalAssessmentSnapshot
    ) throws -> String {
        PrimeNativeNeuralGateInvariantCodec.sha256(
            try canonicalBytes(of: snapshot)
        )
    }
}
