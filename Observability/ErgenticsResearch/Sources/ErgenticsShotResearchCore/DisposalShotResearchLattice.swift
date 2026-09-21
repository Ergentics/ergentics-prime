import Foundation

public enum DisposalShotHypothesisDecision: String, Equatable, Sendable {
    case abstainUnknown = "ABSTAIN_UNKNOWN"
    case modelConsistent = "MODEL_CONSISTENT"
    case modelInconsistent = "MODEL_INCONSISTENT"
}

public enum DisposalShotHypothesisResultDecision: String, Equatable, Sendable {
    case confirmed = "HYPOTHESIS_CONFIRMED"
    case indeterminate = "HYPOTHESIS_INDETERMINATE"
    case refuted = "HYPOTHESIS_REFUTED"
}

public struct DisposalShotHypothesisReport: Equatable, Sendable {
    public let decision: DisposalShotHypothesisDecision
    public let matchedRuleID: String
    public let inputSHA256: String
    public let latticeSHA256: String
    public let predicateVectorSHA256: String
    public let commitmentMerkleRootSHA256: String
    public let canonicalJSON: Data
    public let canonicalJSONWithLF: Data
}

public struct DisposalShotHypothesisResultReport: Equatable, Sendable {
    public let decision: DisposalShotHypothesisResultDecision
    public let hypothesisInputSHA256: String
    public let resultInputSHA256: String
    public let deltaMerkleRootSHA256: String
    public let canonicalJSON: Data
    public let canonicalJSONWithLF: Data
}

/// A sibling research lattice. It is deliberately not part of the operational
/// disposal-lattice resource pack and has no controller or launch authority.
public enum DisposalShotResearchLatticeResources {
    public static let hypothesisLatticeWithLF: Data = {
        let line = #"{"authority_vector":"00000000","evaluation":{"default":"ABSTAIN_UNKNOWN","order":["H10","H20","H30","H40","H80"],"strategy":"FIRST_MATCH_EXACT_REGISTERED_HYPOTHESIS_PREDICATES_ONLY"},"rules":[{"all":["required_contradiction_count>0"],"output":"MODEL_INCONSISTENT","rule_id":"H10"},{"all":["required_constraint_failure_count>0"],"output":"MODEL_INCONSISTENT","rule_id":"H20"},{"all":["required_unknown_count>0"],"output":"ABSTAIN_UNKNOWN","rule_id":"H30"},{"all":["hypothesis_count>0","identity_binding_count>0","required_contradiction_count=0","required_constraint_failure_count=0","required_unknown_count=0"],"output":"MODEL_CONSISTENT","rule_id":"H40"},{"all":["input_admitted=true"],"output":"ABSTAIN_UNKNOWN","rule_id":"H80"}],"schema":"ergentics_shot_hypothesis_lattice_v1","states":["ABSTAIN_UNKNOWN","MODEL_CONSISTENT","MODEL_INCONSISTENT"],"status":"NONAUTHORITATIVE_RESEARCH_HYPOTHESIS_NO_LAUNCH_AUTHORITY"}"#
        return Data((line + "\n").utf8)
    }()
}

public enum DisposalShotHypothesisChecker {
    public static let maximumInputBytes = 1_048_576

    public static func evaluate(
        exactCanonicalJSON data: Data
    ) throws -> DisposalShotHypothesisReport {
        let registration = try DisposalShotResearchRegistration.parse(data)
        let lattice = try DisposalShotResearchLattice.load()
        let counts = registration.counts
        let predicateNames = lattice.orderedUniquePredicates
        let predicateEvaluations = try predicateNames.map { predicate in
            (predicate, try DisposalShotResearchLattice.evaluate(predicate, counts: counts))
        }
        let values = Dictionary(uniqueKeysWithValues: predicateEvaluations)
        guard let rule = lattice.rules.first(where: { rule in
            rule.predicates.allSatisfy { values[$0] == true }
        }) else {
            throw DisposalProjectionRejection(code: "HYPOTHESIS_LATTICE_NO_MATCH")
        }
        guard let decision = DisposalShotHypothesisDecision(rawValue: rule.output) else {
            throw DisposalProjectionRejection(code: "HYPOTHESIS_LATTICE_OUTPUT")
        }

        let predicateVectorComponents = predicateEvaluations.flatMap {
            [$0.0, $0.1 ? "TRUE" : "FALSE"]
        }
        let predicateVectorSHA256 = disposalLengthFramedID(
            "ergentics-shot-hypothesis-predicate-vector-v1",
            predicateVectorComponents)
        let commitment = try registration.commitment()
        let latticeData = DisposalShotResearchLatticeResources.hypothesisLatticeWithLF

        let predicateJSON: [DisposalJSONValue] = predicateEvaluations.map {
            disposalShotJSONObject([
                "predicate": disposalJSONString($0.0),
                "value": disposalJSONBoolean($0.1),
            ])
        }
        let reportData = disposalCanonicalObject([
            "authority_vector": disposalJSONString("00000000"),
            "authoritative": disposalJSONBoolean(false),
            "commitment": disposalShotJSONObject([
                "algorithm": disposalJSONString("SHA256_LFID_RFC6962_SPLIT_V1"),
                "leaf_count": disposalJSONNumber(commitment.leafCount),
                "merkle_root_sha256": disposalJSONString(commitment.root),
                "tree_shape": disposalJSONString("RFC6962_LARGEST_POWER_OF_TWO_SPLIT"),
            ]),
            "decision": disposalJSONString(decision.rawValue),
            "decision_scope": disposalJSONString("STRUCTURAL_REGISTERED_MODEL_ONLY"),
            "hypothesis_count": disposalJSONNumber(counts.hypothesisCount),
            "identity_binding_count": disposalJSONNumber(counts.identityBindingCount),
            "identity_binding_scope": disposalJSONString(
                "DECLARED_CONTENT_ADDRESS_REQUIRES_SEPARATE_OUTER_ADMISSION"),
            "input_byte_count": disposalJSONNumber(data.count),
            "input_sha256": disposalJSONString(disposalSHA256(data)),
            "lattice_byte_count": disposalJSONNumber(latticeData.count),
            "lattice_sha256": disposalJSONString(disposalSHA256(latticeData)),
            "matched_rule_id": disposalJSONString(rule.id),
            "may_authorize_launch": disposalJSONBoolean(false),
            "may_feed_controller": disposalJSONBoolean(false),
            "measurement_protocol": disposalJSONString(
                "MACH_CONTINUOUS_TIME_BEFORE_ACTUATION_THROUGH_TERMINAL_CONSERVATION"),
            "predicate_evaluations": disposalShotJSONArray(predicateJSON),
            "predicate_vector_sha256": disposalJSONString(predicateVectorSHA256),
            "prose_may_supply_fact": disposalJSONBoolean(false),
            "required_constraint_failure_count": disposalJSONNumber(
                counts.requiredConstraintFailureCount),
            "required_contradiction_count": disposalJSONNumber(
                counts.requiredContradictionCount),
            "required_unknown_count": disposalJSONNumber(counts.requiredUnknownCount),
            "schema": disposalJSONString("ergentics_shot_hypothesis_report_v1"),
            "shot_class": disposalJSONString(registration.shotClass),
            "status": disposalJSONString("HYPOTHESIS_EVALUATED_NO_LIVE_AUTHORITY"),
            "study_id": disposalJSONString(registration.studyID),
            "witness_count": disposalJSONNumber(registration.witnesses.count),
        ])
        var withLF = reportData
        withLF.append(0x0a)
        return .init(
            decision: decision,
            matchedRuleID: rule.id,
            inputSHA256: disposalSHA256(data),
            latticeSHA256: disposalSHA256(latticeData),
            predicateVectorSHA256: predicateVectorSHA256,
            commitmentMerkleRootSHA256: commitment.root,
            canonicalJSON: reportData,
            canonicalJSONWithLF: withLF)
    }
}

public enum DisposalShotHypothesisResultComparator {
    public static func compare(
        hypothesisExactCanonicalJSON hypothesisData: Data,
        resultExactCanonicalJSON resultData: Data
    ) throws -> DisposalShotHypothesisResultReport {
        let hypothesis = try DisposalShotResearchRegistration.parse(hypothesisData)
        let hypothesisReport = try DisposalShotHypothesisChecker.evaluate(
            exactCanonicalJSON: hypothesisData)
        let comparisonQualified = hypothesisReport.decision == .modelConsistent
        let result = try DisposalShotResearchResult.parse(
            resultData,
            expectedStudyID: hypothesis.studyID,
            expectedShotClass: hypothesis.shotClass,
            admittedResultKeys: Set(hypothesis.hypotheses.map(\.resultKey)))

        var requiredRefuted = 0
        var requiredIndeterminate = comparisonQualified ? 0 : 1
        var requiredConfirmed = 0
        var deltaRows: [DisposalShotDeltaRow] = []

        let classClassification: DisposalShotDeltaClassification
        switch result.observedResultClass {
        case "UNKNOWN":
            classClassification = .indeterminate
            requiredIndeterminate += 1
        case hypothesis.predictedResultClass:
            classClassification = .confirmed
            requiredConfirmed += 1
        default:
            classClassification = .refuted
            requiredRefuted += 1
        }
        deltaRows.append(.init(
            expected: hypothesis.predictedResultClass,
            hypothesisID: "OVERALL_RESULT_CLASS",
            observed: result.observedResultClass,
            required: true,
            resultKey: "OVERALL_RESULT_CLASS",
            classification: classClassification,
            witnessSetSHA256: disposalShotWitnessSetSHA(
                result.observedResultClassWitnessSHA256s)))

        let observations = Dictionary(uniqueKeysWithValues: result.observations.map {
            ($0.resultKey, $0)
        })
        for registered in hypothesis.hypotheses {
            let observed = observations[registered.resultKey]?.value ?? "UNKNOWN"
            let classification: DisposalShotDeltaClassification
            if observed == "UNKNOWN" {
                classification = .indeterminate
            } else if observed == registered.expectedValue {
                classification = .confirmed
            } else {
                classification = .refuted
            }
            if registered.required {
                switch classification {
                case .confirmed: requiredConfirmed += 1
                case .indeterminate: requiredIndeterminate += 1
                case .refuted: requiredRefuted += 1
                }
            }
            deltaRows.append(.init(
                expected: registered.expectedValue,
                hypothesisID: registered.id,
                observed: observed,
                required: registered.required,
                resultKey: registered.resultKey,
                classification: classification,
                witnessSetSHA256: disposalShotWitnessSetSHA(
                    observations[registered.resultKey]?.witnessSHA256s ?? [])))
        }

        let decision: DisposalShotHypothesisResultDecision
        if !comparisonQualified {
            decision = .indeterminate
        } else if requiredRefuted > 0 {
            decision = .refuted
        } else if requiredIndeterminate > 0 {
            decision = .indeterminate
        } else {
            decision = .confirmed
        }

        var deltaLeaves = deltaRows.map { row in
            disposalLengthFramedID(
                "ergentics-shot-hypothesis-result-delta-leaf-v1",
                [
                    "ERGENTICS_SHOT_HYPOTHESIS_RESULT_DELTA_V1",
                    row.hypothesisID,
                    row.resultKey,
                    row.expected,
                    row.observed,
                    row.required ? "TRUE" : "FALSE",
                    row.classification.rawValue,
                    row.witnessSetSHA256,
                ])
        }
        deltaLeaves.append(disposalLengthFramedID(
            "ergentics-shot-hypothesis-result-delta-leaf-v1",
            [
                "ERGENTICS_SHOT_HYPOTHESIS_RESULT_DELTA_V1", "PRECHECK_QUALIFICATION",
                hypothesisReport.decision.rawValue, comparisonQualified ? "TRUE" : "FALSE",
            ]))
        deltaLeaves.append(disposalLengthFramedID(
            "ergentics-shot-hypothesis-result-delta-leaf-v1",
            [
                "ERGENTICS_SHOT_HYPOTHESIS_RESULT_DELTA_V1", "MEASUREMENT",
                String(result.measurement.startContinuousTicks),
                String(result.measurement.endContinuousTicks),
                String(result.measurement.timebaseNumerator),
                String(result.measurement.timebaseDenominator),
                String(result.measurement.elapsedNanosecondsNumerator),
                String(result.measurement.elapsedNanosecondsDenominator),
                result.measurement.startUTC, result.measurement.endUTC,
                result.measurement.startWitnessSHA256, result.measurement.endWitnessSHA256,
            ]))
        let deltaRoot = try DisposalShotResearchMerkle.root(
            leaves: deltaLeaves,
            chainDomain: "ERGENTICS_SHOT_HYPOTHESIS_RESULT_DELTA_V1",
            nodeDomain: "ergentics-shot-hypothesis-result-delta-node-v1")

        let deltaJSON = deltaRows.map { row in
            disposalShotJSONObject([
                "classification": disposalJSONString(row.classification.rawValue),
                "expected_value": disposalJSONString(row.expected),
                "hypothesis_id": disposalJSONString(row.hypothesisID),
                "observed_value": disposalJSONString(row.observed),
                "required": disposalJSONBoolean(row.required),
                "result_key": disposalJSONString(row.resultKey),
                "witness_set_sha256": disposalJSONString(row.witnessSetSHA256),
            ])
        }
        let reportData = disposalCanonicalObject([
            "authority_vector": disposalJSONString("00000000"),
            "authoritative": disposalJSONBoolean(false),
            "comparison_qualified_by_precheck": disposalJSONBoolean(comparisonQualified),
            "decision": disposalJSONString(decision.rawValue),
            "delta_leaf_count": disposalJSONNumber(deltaLeaves.count),
            "delta_merkle_root_sha256": disposalJSONString(deltaRoot),
            "delta_merkle_scope": disposalJSONString(
                "CLASSIFICATIONS_WITNESS_SETS_PRECHECK_AND_MEASUREMENT"),
            "delta_rows": disposalShotJSONArray(deltaJSON),
            "hypothesis_evaluation_decision": disposalJSONString(
                hypothesisReport.decision.rawValue),
            "hypothesis_input_sha256": disposalJSONString(disposalSHA256(hypothesisData)),
            "hypothesis_report_sha256": disposalJSONString(
                disposalSHA256(hypothesisReport.canonicalJSON)),
            "may_authorize_launch": disposalJSONBoolean(false),
            "may_feed_controller": disposalJSONBoolean(false),
            "prose_may_supply_fact": disposalJSONBoolean(false),
            "required_confirmed_count": disposalJSONNumber(requiredConfirmed),
            "required_indeterminate_count": disposalJSONNumber(requiredIndeterminate),
            "required_refuted_count": disposalJSONNumber(requiredRefuted),
            "result_input_sha256": disposalJSONString(disposalSHA256(resultData)),
            "result_witness_count": disposalJSONNumber(result.witnesses.count),
            "schema": disposalJSONString("ergentics_shot_hypothesis_result_delta_v1"),
            "shot_class": disposalJSONString(hypothesis.shotClass),
            "timing": disposalShotJSONObject([
                "elapsed_nanoseconds_denominator": disposalShotJSONUInt64(
                    result.measurement.elapsedNanosecondsDenominator),
                "elapsed_nanoseconds_numerator": disposalShotJSONUInt64(
                    result.measurement.elapsedNanosecondsNumerator),
                "end_continuous_ticks": disposalShotJSONUInt64(
                    result.measurement.endContinuousTicks),
                "end_utc": disposalJSONString(result.measurement.endUTC),
                "end_witness_sha256": disposalJSONString(
                    result.measurement.endWitnessSHA256),
                "start_continuous_ticks": disposalShotJSONUInt64(
                    result.measurement.startContinuousTicks),
                "start_utc": disposalJSONString(result.measurement.startUTC),
                "start_witness_sha256": disposalJSONString(
                    result.measurement.startWitnessSHA256),
                "timebase_denominator": disposalShotJSONUInt64(
                    result.measurement.timebaseDenominator),
                "timebase_numerator": disposalShotJSONUInt64(
                    result.measurement.timebaseNumerator),
                "utc_stamps_display_only": disposalJSONBoolean(true),
            ]),
            "status": disposalJSONString("HYPOTHESIS_RESULT_COMPARED_NO_LIVE_AUTHORITY"),
            "study_id": disposalJSONString(hypothesis.studyID),
        ])
        var withLF = reportData
        withLF.append(0x0a)
        return .init(
            decision: decision,
            hypothesisInputSHA256: disposalSHA256(hypothesisData),
            resultInputSHA256: disposalSHA256(resultData),
            deltaMerkleRootSHA256: deltaRoot,
            canonicalJSON: reportData,
            canonicalJSONWithLF: withLF)
    }
}

private enum DisposalShotEpistemicValue: String {
    case falseValue = "FALSE"
    case trueValue = "TRUE"
    case unknown = "UNKNOWN"
}

private struct DisposalShotConstraint {
    let id: String
    let required: Bool
    let statementSHA256: String
    let value: DisposalShotEpistemicValue
    let witnessSHA256s: [String]
    let canonicalSHA256: String
}

private struct DisposalShotHypothesis {
    let expectedValue: String
    let id: String
    let modelValue: DisposalShotEpistemicValue
    let required: Bool
    let resultKey: String
    let statementSHA256: String
    let witnessSHA256s: [String]
    let canonicalSHA256: String
}

private struct DisposalShotIdentityBinding {
    let byteCount: UInt64
    let role: String
    let sha256: String
    let canonicalSHA256: String
}

private struct DisposalShotWitness {
    let byteCount: UInt64
    let components: [String]
    let kind: String
    let sha256: String

    func matches(kind: String, components: [String]) -> Bool {
        self.kind == kind && self.components == components
    }

    static func parseInventory(
        _ values: [DisposalJSONValue],
        admittedKinds: Set<String>,
        code: String
    ) throws -> [DisposalShotWitness] {
        let witnesses: [DisposalShotWitness] = try values.map { value in
            let row = try disposalShotObject(
                value,
                exactKeys: ["byte_count", "components", "kind", "sha256"],
                code: code)
            let kind = try disposalShotToken(
                try disposalShotString(row, "kind", code), code: code)
            try disposalShotRequire(admittedKinds.contains(kind), code)
            let components = try disposalShotStringArray(
                try disposalShotValue(row, "components", code), code: code).map {
                    try disposalShotToken($0, code: code)
                }
            try disposalShotRequire(
                !components.isEmpty && components.count <= 8,
                code)
            let byteCount = try disposalShotUInt64(row, "byte_count", code)
            let sha256 = try disposalShotDigest(row, "sha256", code)
            let digestFree = disposalCanonicalObject([
                "components": disposalShotJSONArray(components.map(disposalJSONString)),
                "kind": disposalJSONString(kind),
            ])
            try disposalShotRequire(byteCount == UInt64(digestFree.count), code)
            try disposalShotRequire(sha256 == disposalSHA256(digestFree), code)
            return .init(
                byteCount: byteCount,
                components: components,
                kind: kind,
                sha256: sha256)
        }
        try disposalShotRequireSortedUnique(witnesses.map(\.sha256), code: code)
        return witnesses
    }
}

private struct DisposalShotResearchCounts {
    let hypothesisCount: Int
    let identityBindingCount: Int
    let requiredConstraintFailureCount: Int
    let requiredContradictionCount: Int
    let requiredUnknownCount: Int
}

private struct DisposalShotResearchRegistration {
    let constraints: [DisposalShotConstraint]
    let hypotheses: [DisposalShotHypothesis]
    let identityBindings: [DisposalShotIdentityBinding]
    let predictedResultClass: String
    let shotClass: String
    let studyID: String
    let unknowns: [String]
    let witnesses: [DisposalShotWitness]

    var counts: DisposalShotResearchCounts {
        let constraintFailures = constraints.filter {
            $0.required && $0.value == .falseValue
        }.count
        let contradictions = hypotheses.filter {
            $0.required && $0.modelValue != .unknown &&
                $0.modelValue.rawValue != $0.expectedValue
        }.count
        let unknownCount = unknowns.count + constraints.filter {
            $0.required && $0.value == .unknown
        }.count + hypotheses.filter {
            $0.required && $0.modelValue == .unknown
        }.count
        return .init(
            hypothesisCount: hypotheses.count,
            identityBindingCount: identityBindings.count,
            requiredConstraintFailureCount: constraintFailures,
            requiredContradictionCount: contradictions,
            requiredUnknownCount: unknownCount)
    }

    static func parse(_ data: Data) throws -> Self {
        try disposalShotRequire(
            !data.isEmpty && data.count <= DisposalShotHypothesisChecker.maximumInputBytes,
            "HYPOTHESIS_INPUT_SIZE")
        var parser = DisposalCanonicalJSONParser(
            data: data,
            frameOrdinal: 1,
            journalByteOffset: 0,
            maximumDepth: 16,
            maximumEntries: 16_384,
            maximumStringBytes: 1_024)
        let root = try parser.parse()
        try disposalShotRequire(root.canonicalData() == data, "HYPOTHESIS_INPUT_NOT_CANONICAL")
        let object = try disposalShotObject(
            root,
            exactKeys: [
                "authoritative", "authority_vector", "constraints", "hypotheses",
                "identity_bindings", "may_feed_controller", "measurement_plan",
                "predicted_result_class", "prose_may_supply_fact", "schema", "shot_class",
                "status", "study_id", "unknowns", "witness_inventory",
            ],
            code: "HYPOTHESIS_ROOT")
        try disposalShotRequire(
            try disposalShotBool(object, "authoritative", "HYPOTHESIS_AUTHORITATIVE") == false,
            "HYPOTHESIS_AUTHORITATIVE")
        try disposalShotExactString(object, "authority_vector", "00000000", "HYPOTHESIS_AUTHORITY")
        try disposalShotRequire(
            try disposalShotBool(object, "may_feed_controller", "HYPOTHESIS_CONTROLLER_FEED") == false,
            "HYPOTHESIS_CONTROLLER_FEED")
        try disposalShotRequire(
            try disposalShotBool(object, "prose_may_supply_fact", "HYPOTHESIS_PROSE_FACT") == false,
            "HYPOTHESIS_PROSE_FACT")
        try disposalShotExactString(
            object, "schema", "ergentics_shot_hypothesis_registration_v1", "HYPOTHESIS_SCHEMA")
        try disposalShotExactString(
            object, "status", "REGISTERED_HYPOTHESIS", "HYPOTHESIS_STATUS")
        let measurementPlan = try disposalShotObject(
            try disposalShotValue(object, "measurement_plan", "HYPOTHESIS_MEASUREMENT_PLAN"),
            exactKeys: ["clock", "end_boundary", "start_boundary", "utc_display"],
            code: "HYPOTHESIS_MEASUREMENT_PLAN")
        try disposalShotExactString(
            measurementPlan, "clock", "MACH_CONTINUOUS_TIME", "HYPOTHESIS_MEASUREMENT_CLOCK")
        try disposalShotExactString(
            measurementPlan,
            "start_boundary",
            "BEFORE_FIRST_LIVE_ACTUATION",
            "HYPOTHESIS_MEASUREMENT_START")
        try disposalShotExactString(
            measurementPlan,
            "end_boundary",
            "AFTER_TERMINAL_CONSERVATION",
            "HYPOTHESIS_MEASUREMENT_END")
        try disposalShotExactString(
            measurementPlan,
            "utc_display",
            "RFC3339_NANOSECONDS_DISPLAY_ONLY",
            "HYPOTHESIS_MEASUREMENT_UTC")

        let studyID = try disposalShotToken(
            try disposalShotString(object, "study_id", "HYPOTHESIS_STUDY_ID"),
            code: "HYPOTHESIS_STUDY_ID")
        let shotClass = try disposalShotToken(
            try disposalShotString(object, "shot_class", "HYPOTHESIS_SHOT_CLASS"),
            code: "HYPOTHESIS_SHOT_CLASS")
        let predictedResultClass = try disposalShotString(
            object, "predicted_result_class", "HYPOTHESIS_RESULT_CLASS")
        try disposalShotRequire(
            ["ABSTAIN", "FAIL", "PASS"].contains(predictedResultClass),
            "HYPOTHESIS_RESULT_CLASS")

        let constraints: [DisposalShotConstraint] = try disposalShotArray(
            object, "constraints", "HYPOTHESIS_CONSTRAINTS").map { value in
                let row = try disposalShotObject(
                    value,
                    exactKeys: [
                        "constraint_id", "required", "statement_sha256", "value",
                        "witness_sha256",
                    ],
                    code: "HYPOTHESIS_CONSTRAINT")
                let id = try disposalShotToken(
                    try disposalShotString(row, "constraint_id", "HYPOTHESIS_CONSTRAINT_ID"),
                    code: "HYPOTHESIS_CONSTRAINT_ID")
                let rawValue = try disposalShotString(
                    row, "value", "HYPOTHESIS_CONSTRAINT_VALUE")
                guard let epistemic = DisposalShotEpistemicValue(rawValue: rawValue) else {
                    throw DisposalProjectionRejection(code: "HYPOTHESIS_CONSTRAINT_VALUE")
                }
                let witnesses = try disposalShotDigests(
                    try disposalShotArray(row, "witness_sha256", "HYPOTHESIS_CONSTRAINT_WITNESS"),
                    code: "HYPOTHESIS_CONSTRAINT_WITNESS")
                if epistemic != .unknown {
                    try disposalShotRequire(!witnesses.isEmpty, "HYPOTHESIS_CONSTRAINT_WITNESS_REQUIRED")
                }
                return DisposalShotConstraint(
                    id: id,
                    required: try disposalShotBool(row, "required", "HYPOTHESIS_CONSTRAINT_REQUIRED"),
                    statementSHA256: try disposalShotDigest(
                        row, "statement_sha256", "HYPOTHESIS_CONSTRAINT_STATEMENT"),
                    value: epistemic,
                    witnessSHA256s: witnesses,
                    canonicalSHA256: disposalSHA256(value.canonicalData()))
            }
        try disposalShotRequireSortedUnique(
            constraints.map(\.id), code: "HYPOTHESIS_CONSTRAINT_ORDER")

        let hypotheses: [DisposalShotHypothesis] = try disposalShotArray(
            object, "hypotheses", "HYPOTHESIS_HYPOTHESES").map { value in
                let row = try disposalShotObject(
                    value,
                    exactKeys: [
                        "expected_value", "hypothesis_id", "model_value", "required",
                        "result_key", "statement_sha256", "witness_sha256",
                    ],
                    code: "HYPOTHESIS_ROW")
                let id = try disposalShotToken(
                    try disposalShotString(row, "hypothesis_id", "HYPOTHESIS_ID"),
                    code: "HYPOTHESIS_ID")
                try disposalShotRequire(
                    id != "OVERALL_RESULT_CLASS",
                    "HYPOTHESIS_ID_RESERVED")
                let expected = try disposalShotString(row, "expected_value", "HYPOTHESIS_EXPECTED")
                try disposalShotRequire(["FALSE", "TRUE"].contains(expected), "HYPOTHESIS_EXPECTED")
                let rawModel = try disposalShotString(row, "model_value", "HYPOTHESIS_MODEL_VALUE")
                guard let model = DisposalShotEpistemicValue(rawValue: rawModel) else {
                    throw DisposalProjectionRejection(code: "HYPOTHESIS_MODEL_VALUE")
                }
                let witnesses = try disposalShotDigests(
                    try disposalShotArray(row, "witness_sha256", "HYPOTHESIS_WITNESS"),
                    code: "HYPOTHESIS_WITNESS")
                if model != .unknown {
                    try disposalShotRequire(!witnesses.isEmpty, "HYPOTHESIS_WITNESS_REQUIRED")
                }
                let resultKey = try disposalShotToken(
                    try disposalShotString(row, "result_key", "HYPOTHESIS_RESULT_KEY"),
                    code: "HYPOTHESIS_RESULT_KEY")
                try disposalShotRequire(
                    resultKey != "OVERALL_RESULT_CLASS",
                    "HYPOTHESIS_RESULT_KEY_RESERVED")
                return DisposalShotHypothesis(
                    expectedValue: expected,
                    id: id,
                    modelValue: model,
                    required: try disposalShotBool(row, "required", "HYPOTHESIS_REQUIRED"),
                    resultKey: resultKey,
                    statementSHA256: try disposalShotDigest(
                        row, "statement_sha256", "HYPOTHESIS_STATEMENT"),
                    witnessSHA256s: witnesses,
                    canonicalSHA256: disposalSHA256(value.canonicalData()))
            }
        try disposalShotRequireSortedUnique(hypotheses.map(\.id), code: "HYPOTHESIS_ORDER")
        try disposalShotRequire(
            Set(hypotheses.map(\.resultKey)).count == hypotheses.count,
            "HYPOTHESIS_RESULT_KEY_DUPLICATE")

        let identities: [DisposalShotIdentityBinding] = try disposalShotArray(
            object, "identity_bindings", "HYPOTHESIS_IDENTITIES").map { value in
                let row = try disposalShotObject(
                    value,
                    exactKeys: ["byte_count", "role", "sha256"],
                    code: "HYPOTHESIS_IDENTITY")
                let byteCount = try disposalShotUInt64(
                    row, "byte_count", "HYPOTHESIS_IDENTITY_BYTE_COUNT")
                try disposalShotRequire(byteCount > 0, "HYPOTHESIS_IDENTITY_BYTE_COUNT")
                return DisposalShotIdentityBinding(
                    byteCount: byteCount,
                    role: try disposalShotToken(
                        try disposalShotString(row, "role", "HYPOTHESIS_IDENTITY_ROLE"),
                        code: "HYPOTHESIS_IDENTITY_ROLE"),
                    sha256: try disposalShotDigest(row, "sha256", "HYPOTHESIS_IDENTITY_SHA"),
                    canonicalSHA256: disposalSHA256(value.canonicalData()))
            }
        try disposalShotRequireSortedUnique(
            identities.map(\.role), code: "HYPOTHESIS_IDENTITY_ORDER")

        let witnesses = try DisposalShotWitness.parseInventory(
            try disposalShotArray(
                object, "witness_inventory", "HYPOTHESIS_WITNESS_INVENTORY"),
            admittedKinds: ["CONSTRAINT_VALUE", "HYPOTHESIS_MODEL_VALUE"],
            code: "HYPOTHESIS_WITNESS_INVENTORY")
        let witnessesBySHA = Dictionary(uniqueKeysWithValues: witnesses.map { ($0.sha256, $0) })
        for constraint in constraints {
            try disposalShotRequire(
                constraint.witnessSHA256s.allSatisfy { witnessesBySHA[$0] != nil },
                "HYPOTHESIS_CONSTRAINT_WITNESS_UNRESOLVED")
            if constraint.value != .unknown || !constraint.witnessSHA256s.isEmpty {
                try disposalShotRequire(
                    constraint.witnessSHA256s.contains { sha in
                        witnessesBySHA[sha]?.matches(
                            kind: "CONSTRAINT_VALUE",
                            components: [constraint.id, constraint.value.rawValue]) == true
                    },
                    "HYPOTHESIS_CONSTRAINT_WITNESS_JOIN")
            }
        }
        for hypothesis in hypotheses {
            try disposalShotRequire(
                hypothesis.witnessSHA256s.allSatisfy { witnessesBySHA[$0] != nil },
                "HYPOTHESIS_WITNESS_UNRESOLVED")
            if hypothesis.modelValue != .unknown || !hypothesis.witnessSHA256s.isEmpty {
                try disposalShotRequire(
                    hypothesis.witnessSHA256s.contains { sha in
                        witnessesBySHA[sha]?.matches(
                            kind: "HYPOTHESIS_MODEL_VALUE",
                            components: [hypothesis.id, hypothesis.modelValue.rawValue]) == true
                    },
                    "HYPOTHESIS_WITNESS_JOIN")
            }
        }
        let referencedWitnesses = Set(
            constraints.flatMap(\.witnessSHA256s) + hypotheses.flatMap(\.witnessSHA256s))
        try disposalShotRequire(
            referencedWitnesses == Set(witnesses.map(\.sha256)),
            "HYPOTHESIS_WITNESS_INVENTORY_UNUSED")

        let unknowns = try disposalShotArray(
            object, "unknowns", "HYPOTHESIS_UNKNOWNS").map { value in
                guard let string = value.stringValue() else {
                    throw DisposalProjectionRejection(code: "HYPOTHESIS_UNKNOWN_ID")
                }
                return try disposalShotToken(string, code: "HYPOTHESIS_UNKNOWN_ID")
            }
        try disposalShotRequireSortedUnique(unknowns, code: "HYPOTHESIS_UNKNOWN_ORDER")

        return .init(
            constraints: constraints,
            hypotheses: hypotheses,
            identityBindings: identities,
            predictedResultClass: predictedResultClass,
            shotClass: shotClass,
            studyID: studyID,
            unknowns: unknowns,
            witnesses: witnesses)
    }

    func commitment() throws -> (root: String, leafCount: Int) {
        let chain = "ERGENTICS_SHOT_HYPOTHESIS_COMMITMENT_V1"
        var leaves = [disposalLengthFramedID(
            "ergentics-shot-hypothesis-commitment-leaf-v1",
            [
                chain, "METADATA", studyID, shotClass, predictedResultClass,
                "MACH_CONTINUOUS_TIME", "BEFORE_FIRST_LIVE_ACTUATION",
                "AFTER_TERMINAL_CONSERVATION", "RFC3339_NANOSECONDS_DISPLAY_ONLY",
            ])]
        leaves += constraints.map {
            disposalLengthFramedID(
                "ergentics-shot-hypothesis-commitment-leaf-v1",
                [chain, "CONSTRAINT", $0.id, $0.statementSHA256, $0.canonicalSHA256])
        }
        leaves += hypotheses.map {
            disposalLengthFramedID(
                "ergentics-shot-hypothesis-commitment-leaf-v1",
                [chain, "HYPOTHESIS", $0.id, $0.statementSHA256, $0.canonicalSHA256])
        }
        leaves += identityBindings.map {
            disposalLengthFramedID(
                "ergentics-shot-hypothesis-commitment-leaf-v1",
                [chain, "IDENTITY", $0.role, $0.sha256, String($0.byteCount), $0.canonicalSHA256])
        }
        leaves += unknowns.map {
            disposalLengthFramedID(
                "ergentics-shot-hypothesis-commitment-leaf-v1",
                [chain, "UNKNOWN", $0])
        }
        leaves += witnesses.map {
            disposalLengthFramedID(
                "ergentics-shot-hypothesis-commitment-leaf-v1",
                [chain, "WITNESS", $0.sha256, $0.kind, String($0.byteCount)])
        }
        return (
            try DisposalShotResearchMerkle.root(
                leaves: leaves,
                chainDomain: chain,
                nodeDomain: "ergentics-shot-hypothesis-commitment-node-v1"),
            leaves.count)
    }
}

private struct DisposalShotResultObservation {
    let resultKey: String
    let value: String
    let witnessSHA256s: [String]
}

private struct DisposalShotResearchResult {
    let observations: [DisposalShotResultObservation]
    let observedResultClass: String
    let observedResultClassWitnessSHA256s: [String]
    let measurement: DisposalShotMeasurement
    let witnesses: [DisposalShotWitness]

    static func parse(
        _ data: Data,
        expectedStudyID: String,
        expectedShotClass: String,
        admittedResultKeys: Set<String>
    ) throws -> Self {
        try disposalShotRequire(
            !data.isEmpty && data.count <= DisposalShotHypothesisChecker.maximumInputBytes,
            "HYPOTHESIS_RESULT_INPUT_SIZE")
        var parser = DisposalCanonicalJSONParser(
            data: data,
            frameOrdinal: 2,
            journalByteOffset: 0,
            maximumDepth: 12,
            maximumEntries: 16_384,
            maximumStringBytes: 1_024)
        let root = try parser.parse()
        try disposalShotRequire(root.canonicalData() == data, "HYPOTHESIS_RESULT_NOT_CANONICAL")
        let object = try disposalShotObject(
            root,
            exactKeys: [
                "authoritative", "authority_vector", "may_feed_controller", "measurement_window",
                "observations", "observed_result_class",
                "observed_result_class_witness_sha256", "prose_may_supply_fact", "schema",
                "shot_class", "status", "study_id", "witness_inventory",
            ],
            code: "HYPOTHESIS_RESULT_ROOT")
        try disposalShotRequire(
            try disposalShotBool(object, "authoritative", "HYPOTHESIS_RESULT_AUTHORITATIVE") == false,
            "HYPOTHESIS_RESULT_AUTHORITATIVE")
        try disposalShotExactString(
            object, "authority_vector", "00000000", "HYPOTHESIS_RESULT_AUTHORITY")
        try disposalShotRequire(
            try disposalShotBool(object, "may_feed_controller", "HYPOTHESIS_RESULT_CONTROLLER") == false,
            "HYPOTHESIS_RESULT_CONTROLLER")
        try disposalShotRequire(
            try disposalShotBool(object, "prose_may_supply_fact", "HYPOTHESIS_RESULT_PROSE") == false,
            "HYPOTHESIS_RESULT_PROSE")
        try disposalShotExactString(
            object, "schema", "ergentics_shot_result_observation_v1", "HYPOTHESIS_RESULT_SCHEMA")
        try disposalShotExactString(
            object, "status", "REGISTERED_RESULT", "HYPOTHESIS_RESULT_STATUS")
        try disposalShotExactString(
            object, "study_id", expectedStudyID, "HYPOTHESIS_RESULT_STUDY_JOIN")
        try disposalShotExactString(
            object, "shot_class", expectedShotClass, "HYPOTHESIS_RESULT_SHOT_JOIN")
        let resultClass = try disposalShotString(
            object, "observed_result_class", "HYPOTHESIS_RESULT_CLASS")
        try disposalShotRequire(
            ["ABSTAIN", "FAIL", "PASS", "UNKNOWN"].contains(resultClass),
            "HYPOTHESIS_RESULT_CLASS")
        let witnesses = try DisposalShotWitness.parseInventory(
            try disposalShotArray(
                object, "witness_inventory", "HYPOTHESIS_RESULT_WITNESS_INVENTORY"),
            admittedKinds: [
                "RESULT_CLASS", "RESULT_OBSERVATION", "TIMING_END", "TIMING_START",
            ],
            code: "HYPOTHESIS_RESULT_WITNESS_INVENTORY")
        let witnessesBySHA = Dictionary(uniqueKeysWithValues: witnesses.map { ($0.sha256, $0) })
        let resultClassWitnesses = try disposalShotDigests(
            try disposalShotArray(
                object,
                "observed_result_class_witness_sha256",
                "HYPOTHESIS_RESULT_CLASS_WITNESS"),
            code: "HYPOTHESIS_RESULT_CLASS_WITNESS")
        try disposalShotRequire(!resultClassWitnesses.isEmpty, "HYPOTHESIS_RESULT_CLASS_WITNESS")
        try disposalShotRequire(
            resultClassWitnesses.allSatisfy { witnessesBySHA[$0] != nil },
            "HYPOTHESIS_RESULT_CLASS_WITNESS_UNRESOLVED")
        try disposalShotRequire(
            resultClassWitnesses.contains { sha in
                witnessesBySHA[sha]?.matches(
                    kind: "RESULT_CLASS", components: [resultClass]) == true
            },
            "HYPOTHESIS_RESULT_CLASS_WITNESS_JOIN")
        let observations: [DisposalShotResultObservation] = try disposalShotArray(
            object, "observations", "HYPOTHESIS_RESULT_OBSERVATIONS").map { value in
                let row = try disposalShotObject(
                    value,
                    exactKeys: ["result_key", "value", "witness_sha256"],
                    code: "HYPOTHESIS_RESULT_OBSERVATION")
                let key = try disposalShotToken(
                    try disposalShotString(row, "result_key", "HYPOTHESIS_RESULT_KEY"),
                    code: "HYPOTHESIS_RESULT_KEY")
                try disposalShotRequire(
                    admittedResultKeys.contains(key), "HYPOTHESIS_RESULT_KEY_UNREGISTERED")
                let observed = try disposalShotString(row, "value", "HYPOTHESIS_RESULT_VALUE")
                try disposalShotRequire(
                    ["FALSE", "TRUE", "UNKNOWN"].contains(observed),
                    "HYPOTHESIS_RESULT_VALUE")
                let witnesses = try disposalShotDigests(
                    try disposalShotArray(row, "witness_sha256", "HYPOTHESIS_RESULT_WITNESS"),
                    code: "HYPOTHESIS_RESULT_WITNESS")
                if observed != "UNKNOWN" {
                    try disposalShotRequire(!witnesses.isEmpty, "HYPOTHESIS_RESULT_WITNESS_REQUIRED")
                }
                try disposalShotRequire(
                    witnesses.allSatisfy { witnessesBySHA[$0] != nil },
                    "HYPOTHESIS_RESULT_WITNESS_UNRESOLVED")
                if observed != "UNKNOWN" || !witnesses.isEmpty {
                    try disposalShotRequire(
                        witnesses.contains { sha in
                            witnessesBySHA[sha]?.matches(
                                kind: "RESULT_OBSERVATION",
                                components: [key, observed]) == true
                        },
                        "HYPOTHESIS_RESULT_WITNESS_JOIN")
                }
                return DisposalShotResultObservation(
                    resultKey: key,
                    value: observed,
                    witnessSHA256s: witnesses)
            }
        try disposalShotRequireSortedUnique(
            observations.map(\.resultKey), code: "HYPOTHESIS_RESULT_OBSERVATION_ORDER")
        let measurement = try DisposalShotMeasurement.parse(
            try disposalShotValue(
                object, "measurement_window", "HYPOTHESIS_RESULT_MEASUREMENT"),
            witnessesBySHA: witnessesBySHA)
        let referencedWitnesses = Set(
            resultClassWitnesses + observations.flatMap(\.witnessSHA256s) +
                [measurement.startWitnessSHA256, measurement.endWitnessSHA256])
        try disposalShotRequire(
            referencedWitnesses == Set(witnesses.map(\.sha256)),
            "HYPOTHESIS_RESULT_WITNESS_INVENTORY_UNUSED")
        return .init(
            observations: observations,
            observedResultClass: resultClass,
            observedResultClassWitnessSHA256s: resultClassWitnesses,
            measurement: measurement,
            witnesses: witnesses)
    }
}

private struct DisposalShotMeasurement {
    let elapsedNanosecondsDenominator: UInt64
    let elapsedNanosecondsNumerator: UInt64
    let endContinuousTicks: UInt64
    let endWitnessSHA256: String
    let endUTC: String
    let startContinuousTicks: UInt64
    let startWitnessSHA256: String
    let startUTC: String
    let timebaseDenominator: UInt64
    let timebaseNumerator: UInt64

    static func parse(
        _ value: DisposalJSONValue,
        witnessesBySHA: [String: DisposalShotWitness]
    ) throws -> Self {
        let object = try disposalShotObject(
            value,
            exactKeys: [
                "clock", "elapsed_nanoseconds_denominator", "elapsed_nanoseconds_numerator",
                "end_boundary", "end_continuous_ticks", "end_utc", "end_witness_sha256",
                "start_boundary", "start_continuous_ticks", "start_utc",
                "start_witness_sha256", "timebase_denominator", "timebase_numerator",
            ],
            code: "HYPOTHESIS_RESULT_MEASUREMENT")
        try disposalShotExactString(
            object, "clock", "MACH_CONTINUOUS_TIME", "HYPOTHESIS_RESULT_MEASUREMENT_CLOCK")
        try disposalShotExactString(
            object,
            "start_boundary",
            "BEFORE_FIRST_LIVE_ACTUATION",
            "HYPOTHESIS_RESULT_MEASUREMENT_START")
        try disposalShotExactString(
            object,
            "end_boundary",
            "AFTER_TERMINAL_CONSERVATION",
            "HYPOTHESIS_RESULT_MEASUREMENT_END")
        let start = try disposalShotUInt64(
            object, "start_continuous_ticks", "HYPOTHESIS_RESULT_MEASUREMENT_START_TICKS")
        let end = try disposalShotUInt64(
            object, "end_continuous_ticks", "HYPOTHESIS_RESULT_MEASUREMENT_END_TICKS")
        let numerator = try disposalShotUInt64(
            object, "timebase_numerator", "HYPOTHESIS_RESULT_MEASUREMENT_NUMERATOR")
        let denominator = try disposalShotUInt64(
            object, "timebase_denominator", "HYPOTHESIS_RESULT_MEASUREMENT_DENOMINATOR")
        let elapsedNumerator = try disposalShotUInt64(
            object,
            "elapsed_nanoseconds_numerator",
            "HYPOTHESIS_RESULT_MEASUREMENT_ELAPSED_NUMERATOR")
        let elapsedDenominator = try disposalShotUInt64(
            object,
            "elapsed_nanoseconds_denominator",
            "HYPOTHESIS_RESULT_MEASUREMENT_ELAPSED_DENOMINATOR")
        try disposalShotRequire(end >= start, "HYPOTHESIS_RESULT_MEASUREMENT_TICK_ORDER")
        try disposalShotRequire(
            numerator > 0 && denominator > 0,
            "HYPOTHESIS_RESULT_MEASUREMENT_TIMEBASE")
        let delta = end - start
        try disposalShotRequire(
            delta == 0 || numerator <= UInt64.max / delta,
            "HYPOTHESIS_RESULT_MEASUREMENT_OVERFLOW")
        let unreducedNumerator = delta * numerator
        let divisor = disposalShotGCD(unreducedNumerator, denominator)
        try disposalShotRequire(
            elapsedNumerator == unreducedNumerator / divisor &&
                elapsedDenominator == denominator / divisor,
            "HYPOTHESIS_RESULT_MEASUREMENT_RATIONAL_JOIN")
        let startUTC = try disposalShotString(
            object, "start_utc", "HYPOTHESIS_RESULT_MEASUREMENT_START_UTC")
        let endUTC = try disposalShotString(
            object, "end_utc", "HYPOTHESIS_RESULT_MEASUREMENT_END_UTC")
        try disposalShotRequire(
            disposalShotIsRFC3339Nanoseconds(startUTC),
            "HYPOTHESIS_RESULT_MEASUREMENT_START_UTC")
        try disposalShotRequire(
            disposalShotIsRFC3339Nanoseconds(endUTC),
            "HYPOTHESIS_RESULT_MEASUREMENT_END_UTC")
        let startWitness = try disposalShotDigest(
            object, "start_witness_sha256", "HYPOTHESIS_RESULT_MEASUREMENT_START_WITNESS")
        let endWitness = try disposalShotDigest(
            object, "end_witness_sha256", "HYPOTHESIS_RESULT_MEASUREMENT_END_WITNESS")
        try disposalShotRequire(
            startWitness != endWitness,
            "HYPOTHESIS_RESULT_MEASUREMENT_WITNESS_DISTINCT")
        try disposalShotRequire(
            witnessesBySHA[startWitness]?.matches(
                kind: "TIMING_START",
                components: [
                    "MACH_CONTINUOUS_TIME", "BEFORE_FIRST_LIVE_ACTUATION",
                    String(start), startUTC,
                ]) == true,
            "HYPOTHESIS_RESULT_MEASUREMENT_START_WITNESS_JOIN")
        try disposalShotRequire(
            witnessesBySHA[endWitness]?.matches(
                kind: "TIMING_END",
                components: [
                    "MACH_CONTINUOUS_TIME", "AFTER_TERMINAL_CONSERVATION",
                    String(end), endUTC,
                ]) == true,
            "HYPOTHESIS_RESULT_MEASUREMENT_END_WITNESS_JOIN")
        return .init(
            elapsedNanosecondsDenominator: elapsedDenominator,
            elapsedNanosecondsNumerator: elapsedNumerator,
            endContinuousTicks: end,
            endWitnessSHA256: endWitness,
            endUTC: endUTC,
            startContinuousTicks: start,
            startWitnessSHA256: startWitness,
            startUTC: startUTC,
            timebaseDenominator: denominator,
            timebaseNumerator: numerator)
    }
}

private enum DisposalShotDeltaClassification: String {
    case confirmed = "CONFIRMED"
    case indeterminate = "INDETERMINATE"
    case refuted = "REFUTED"
}

private struct DisposalShotDeltaRow {
    let expected: String
    let hypothesisID: String
    let observed: String
    let required: Bool
    let resultKey: String
    let classification: DisposalShotDeltaClassification
    let witnessSetSHA256: String
}

private struct DisposalShotResearchLatticeRule {
    let id: String
    let predicates: [String]
    let output: String
}

private struct DisposalShotResearchLattice {
    let rules: [DisposalShotResearchLatticeRule]

    var orderedUniquePredicates: [String] {
        var seen = Set<String>()
        return rules.flatMap(\.predicates).filter { seen.insert($0).inserted }
    }

    static func load() throws -> Self {
        let framed = DisposalShotResearchLatticeResources.hypothesisLatticeWithLF
        try disposalShotRequire(framed.last == 0x0a, "HYPOTHESIS_LATTICE_LF")
        let data = framed.dropLast()
        var parser = DisposalCanonicalJSONParser(
            data: Data(data), frameOrdinal: 0, journalByteOffset: 0)
        let root = try parser.parse()
        try disposalShotRequire(root.canonicalData() == data, "HYPOTHESIS_LATTICE_CANONICAL")
        let object = try disposalShotObject(
            root,
            exactKeys: ["authority_vector", "evaluation", "rules", "schema", "states", "status"],
            code: "HYPOTHESIS_LATTICE_ROOT")
        try disposalShotExactString(object, "authority_vector", "00000000", "HYPOTHESIS_LATTICE_AUTHORITY")
        try disposalShotExactString(
            object, "schema", "ergentics_shot_hypothesis_lattice_v1", "HYPOTHESIS_LATTICE_SCHEMA")
        try disposalShotExactString(
            object,
            "status",
            "NONAUTHORITATIVE_RESEARCH_HYPOTHESIS_NO_LAUNCH_AUTHORITY",
            "HYPOTHESIS_LATTICE_STATUS")
        let states = try disposalShotStringArray(
            try disposalShotValue(object, "states", "HYPOTHESIS_LATTICE_STATES"),
            code: "HYPOTHESIS_LATTICE_STATES")
        try disposalShotRequire(
            states == ["ABSTAIN_UNKNOWN", "MODEL_CONSISTENT", "MODEL_INCONSISTENT"],
            "HYPOTHESIS_LATTICE_STATES")
        let evaluation = try disposalShotObject(
            try disposalShotValue(object, "evaluation", "HYPOTHESIS_LATTICE_EVALUATION"),
            exactKeys: ["default", "order", "strategy"],
            code: "HYPOTHESIS_LATTICE_EVALUATION")
        try disposalShotExactString(
            evaluation, "default", "ABSTAIN_UNKNOWN", "HYPOTHESIS_LATTICE_DEFAULT")
        try disposalShotExactString(
            evaluation,
            "strategy",
            "FIRST_MATCH_EXACT_REGISTERED_HYPOTHESIS_PREDICATES_ONLY",
            "HYPOTHESIS_LATTICE_STRATEGY")
        let order = try disposalShotStringArray(
            try disposalShotValue(evaluation, "order", "HYPOTHESIS_LATTICE_ORDER"),
            code: "HYPOTHESIS_LATTICE_ORDER")
        try disposalShotRequire(order == ["H10", "H20", "H30", "H40", "H80"], "HYPOTHESIS_LATTICE_ORDER")
        let rules = try disposalShotArray(object, "rules", "HYPOTHESIS_LATTICE_RULES").map { value in
            let rule = try disposalShotObject(
                value, exactKeys: ["all", "output", "rule_id"], code: "HYPOTHESIS_LATTICE_RULE")
            return DisposalShotResearchLatticeRule(
                id: try disposalShotString(rule, "rule_id", "HYPOTHESIS_LATTICE_RULE_ID"),
                predicates: try disposalShotStringArray(
                    try disposalShotValue(rule, "all", "HYPOTHESIS_LATTICE_PREDICATES"),
                    code: "HYPOTHESIS_LATTICE_PREDICATES"),
                output: try disposalShotString(rule, "output", "HYPOTHESIS_LATTICE_OUTPUT"))
        }
        try disposalShotRequire(rules.map(\.id) == order, "HYPOTHESIS_LATTICE_RULE_ORDER")
        try disposalShotRequire(
            rules.map(\.predicates) == [
                ["required_contradiction_count>0"],
                ["required_constraint_failure_count>0"],
                ["required_unknown_count>0"],
                [
                    "hypothesis_count>0", "identity_binding_count>0",
                    "required_contradiction_count=0",
                    "required_constraint_failure_count=0", "required_unknown_count=0",
                ],
                ["input_admitted=true"],
            ],
            "HYPOTHESIS_LATTICE_PREDICATES")
        try disposalShotRequire(
            rules.map(\.output) == [
                "MODEL_INCONSISTENT", "MODEL_INCONSISTENT", "ABSTAIN_UNKNOWN",
                "MODEL_CONSISTENT", "ABSTAIN_UNKNOWN",
            ],
            "HYPOTHESIS_LATTICE_OUTPUTS")
        return .init(rules: rules)
    }

    static func evaluate(
        _ predicate: String,
        counts: DisposalShotResearchCounts
    ) throws -> Bool {
        switch predicate {
        case "required_contradiction_count>0": return counts.requiredContradictionCount > 0
        case "required_constraint_failure_count>0":
            return counts.requiredConstraintFailureCount > 0
        case "required_unknown_count>0": return counts.requiredUnknownCount > 0
        case "hypothesis_count>0": return counts.hypothesisCount > 0
        case "identity_binding_count>0": return counts.identityBindingCount > 0
        case "required_contradiction_count=0": return counts.requiredContradictionCount == 0
        case "required_constraint_failure_count=0":
            return counts.requiredConstraintFailureCount == 0
        case "required_unknown_count=0": return counts.requiredUnknownCount == 0
        case "input_admitted=true": return true
        default: throw DisposalProjectionRejection(code: "HYPOTHESIS_LATTICE_PREDICATE")
        }
    }
}

private enum DisposalShotResearchMerkle {
    static func root(
        leaves: [String],
        chainDomain: String,
        nodeDomain: String
    ) throws -> String {
        try disposalShotRequire(!leaves.isEmpty, "HYPOTHESIS_MERKLE_EMPTY")
        try disposalShotRequire(
            leaves.allSatisfy { disposalIsLowerHex($0, count: 64) },
            "HYPOTHESIS_MERKLE_LEAF")
        return rootUnchecked(leaves, chainDomain: chainDomain, nodeDomain: nodeDomain)
    }

    private static func rootUnchecked(
        _ hashes: [String],
        chainDomain: String,
        nodeDomain: String
    ) -> String {
        if hashes.count == 1 { return hashes[0] }
        let split = largestPowerOfTwoLessThan(hashes.count)
        let left = rootUnchecked(
            Array(hashes[..<split]), chainDomain: chainDomain, nodeDomain: nodeDomain)
        let right = rootUnchecked(
            Array(hashes[split...]), chainDomain: chainDomain, nodeDomain: nodeDomain)
        return disposalLengthFramedID(nodeDomain, [chainDomain, left, right])
    }

    private static func largestPowerOfTwoLessThan(_ count: Int) -> Int {
        precondition(count > 1)
        var power = 1
        while power * 2 < count { power *= 2 }
        return power
    }
}

private func disposalShotObject(
    _ value: DisposalJSONValue,
    exactKeys: Set<String>,
    code: String
) throws -> [String: DisposalJSONValue] {
    guard case .object(let members, _) = value,
          Set(members.map(\.key)) == exactKeys
    else {
        throw DisposalProjectionRejection(code: code)
    }
    return Dictionary(uniqueKeysWithValues: members.map { ($0.key, $0.value) })
}

private func disposalShotValue(
    _ object: [String: DisposalJSONValue],
    _ key: String,
    _ code: String
) throws -> DisposalJSONValue {
    guard let value = object[key] else { throw DisposalProjectionRejection(code: code) }
    return value
}

private func disposalShotString(
    _ object: [String: DisposalJSONValue],
    _ key: String,
    _ code: String
) throws -> String {
    guard let value = object[key]?.stringValue() else {
        throw DisposalProjectionRejection(code: code)
    }
    return value
}

private func disposalShotExactString(
    _ object: [String: DisposalJSONValue],
    _ key: String,
    _ expected: String,
    _ code: String
) throws {
    try disposalShotRequire(try disposalShotString(object, key, code) == expected, code)
}

private func disposalShotBool(
    _ object: [String: DisposalJSONValue],
    _ key: String,
    _ code: String
) throws -> Bool {
    guard let value = object[key]?.booleanValue() else {
        throw DisposalProjectionRejection(code: code)
    }
    return value
}

private func disposalShotUInt64(
    _ object: [String: DisposalJSONValue],
    _ key: String,
    _ code: String
) throws -> UInt64 {
    guard let lexeme = object[key]?.numberLexeme(),
          let value = UInt64(lexeme),
          String(value) == lexeme
    else {
        throw DisposalProjectionRejection(code: code)
    }
    return value
}

private func disposalShotDigest(
    _ object: [String: DisposalJSONValue],
    _ key: String,
    _ code: String
) throws -> String {
    let value = try disposalShotString(object, key, code)
    try disposalShotRequire(disposalIsLowerHex(value, count: 64), code)
    return value
}

private func disposalShotArray(
    _ object: [String: DisposalJSONValue],
    _ key: String,
    _ code: String
) throws -> [DisposalJSONValue] {
    guard case .array(let values, _) = object[key] else {
        throw DisposalProjectionRejection(code: code)
    }
    return values
}

private func disposalShotStringArray(
    _ value: DisposalJSONValue,
    code: String
) throws -> [String] {
    guard case .array(let values, _) = value else {
        throw DisposalProjectionRejection(code: code)
    }
    return try values.map {
        guard let string = $0.stringValue() else {
            throw DisposalProjectionRejection(code: code)
        }
        return string
    }
}

private func disposalShotDigests(
    _ values: [DisposalJSONValue],
    code: String
) throws -> [String] {
    let digests = try values.map { value in
        guard let string = value.stringValue(), disposalIsLowerHex(string, count: 64) else {
            throw DisposalProjectionRejection(code: code)
        }
        return string
    }
    try disposalShotRequireSortedUnique(digests, code: code)
    return digests
}

@discardableResult
private func disposalShotToken(_ value: String, code: String) throws -> String {
    let allowed = value.utf8.allSatisfy {
        (0x30...0x39).contains($0) || (0x41...0x5a).contains($0) ||
            (0x61...0x7a).contains($0) || [0x2d, 0x2e, 0x3a, 0x5f].contains($0)
    }
    try disposalShotRequire(
        !value.isEmpty && value.utf8.count <= 128 && allowed,
        code)
    return value
}

private func disposalShotRequireSortedUnique(
    _ values: [String],
    code: String
) throws {
    try disposalShotRequire(
        values == values.sorted(by: { $0.utf8.lexicographicallyPrecedes($1.utf8) }) &&
            Set(values).count == values.count,
        code)
}

private func disposalShotWitnessSetSHA(_ digests: [String]) -> String {
    disposalLengthFramedID(
        "ergentics-shot-witness-set-v1",
        [String(digests.count)] + digests)
}

private func disposalShotGCD(_ left: UInt64, _ right: UInt64) -> UInt64 {
    var a = left
    var b = right
    while b != 0 {
        let remainder = a % b
        a = b
        b = remainder
    }
    return a
}

private func disposalShotIsRFC3339Nanoseconds(_ value: String) -> Bool {
    let bytes = Array(value.utf8)
    guard bytes.count == 30,
          bytes[4] == 0x2d, bytes[7] == 0x2d, bytes[10] == 0x54,
          bytes[13] == 0x3a, bytes[16] == 0x3a, bytes[19] == 0x2e,
          bytes[29] == 0x5a
    else { return false }
    let punctuation = Set([4, 7, 10, 13, 16, 19, 29])
    guard bytes.indices.filter({ !punctuation.contains($0) }).allSatisfy({
        (0x30...0x39).contains(bytes[$0])
    }) else { return false }
    func decimal(_ start: Int, _ count: Int) -> Int {
        bytes[start..<(start + count)].reduce(0) { $0 * 10 + Int($1 - 0x30) }
    }
    let year = decimal(0, 4)
    let month = decimal(5, 2)
    let day = decimal(8, 2)
    let hour = decimal(11, 2)
    let minute = decimal(14, 2)
    let second = decimal(17, 2)
    guard (1...12).contains(month) else { return false }
    let isLeapYear = year.isMultiple(of: 4) &&
        (!year.isMultiple(of: 100) || year.isMultiple(of: 400))
    let daysInMonth = [
        31, isLeapYear ? 29 : 28, 31, 30, 31, 30,
        31, 31, 30, 31, 30, 31,
    ][month - 1]
    return (1...daysInMonth).contains(day) &&
        (0...23).contains(hour) && (0...59).contains(minute) &&
        (0...59).contains(second)
}

private func disposalShotRequire(_ condition: @autoclosure () throws -> Bool, _ code: String) throws {
    guard try condition() else { throw DisposalProjectionRejection(code: code) }
}

private func disposalShotJSONObject(
    _ members: [String: DisposalJSONValue]
) -> DisposalJSONValue {
    .object(
        members.map { DisposalJSONObjectMember(key: $0.key, value: $0.value) },
        disposalZeroSpan)
}

private func disposalShotJSONArray(_ values: [DisposalJSONValue]) -> DisposalJSONValue {
    .array(values, disposalZeroSpan)
}

private func disposalShotJSONUInt64(_ value: UInt64) -> DisposalJSONValue {
    .number(String(value), disposalZeroSpan)
}
