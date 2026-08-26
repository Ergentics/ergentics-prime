import Foundation

private struct DisposalGraphNodeRow: Sendable {
    let id: String
    let kind: String
    let key: String
    let label: String
    let databaseRole: String
    let sourceRowID: String
}

private struct DisposalGraphEdgeRow: Sendable {
    let id: String
    let from: String
    let predicate: String
    let to: String
    let databaseRole: String
    let sourceRowID: String
    let pointer: String?
    let grade: String
}

private struct DisposalTypedEvidenceGraphRows: Sendable {
    let nodes: [DisposalGraphNodeRow]
    let edges: [DisposalGraphEdgeRow]
}

private struct DisposalLatticeRule: Sendable {
    let id: String
    let clauses: [String]
    let output: String
}

private struct DisposalLatticePredicate: Sendable {
    let ordinal: Int
    let ruleOrdinal: Int
    let ruleID: String
    let clauseOrdinal: Int
    let clause: String
    let lhs: String
    let comparisonOperator: String
    let rhs: String
    let actualScalar: String
    let normalizedState: String
    let sourceCount: Int
    let sourceSetSHA256: String
    let predicateSHA256: String
}

private struct DisposalLatticeDecision: Sendable {
    let ruleID: String
    let stateClass: String
    let predicates: [DisposalLatticePredicate]
    let predicateVectorSHA256: String
}

private struct DisposalMachineFact: Sendable {
    let table: String
    let rowID: String
    let sourceFrameID: String?
    let visibleOrdinal: Int
    let incomplete: Bool
    let exactRowSHA256: String
    let normalizedFactSHA256: String
    let attributes: [String: String]
}

private struct DisposalMachineStateRow: Sendable {
    let id: String
    let prefixOrdinal: Int
    let predecessorID: String?
    let ancestrySHA256: String
    let highWaterFrameNodeID: String?
    let highWaterFrameLFSHA256: String?
    let ruleID: String
    let predicateVectorSHA256: String
    let stateClass: String
    let derivedPostHocMerkleRootSHA256: String
    let derivedPostHocMerkleLeafCount: Int
}

private struct DisposalMachineTransitionRow: Sendable {
    let id: String
    let fromStateID: String
    let toStateID: String
    let acceptedFrameNodeID: String
    let acceptedFrameLFSHA256: String
    let ruleID: String
    let stateClass: String
    let predicateVectorSHA256: String
    let derivedPostHocSourceSetSHA256: String
    let predecessorDerivedPostHocMerkleRootSHA256: String
    let predecessorDerivedPostHocMerkleLeafCount: Int
    let preconservationMerkleCommitted: String
    let preconservationCommitmentWitnessID: String?
    let predicates: [DisposalLatticePredicate]
}

private struct DisposalMachineWitnessRow: Sendable {
    let id: String
    let table: String
    let rowID: String
    let exactRowSHA256: String
    let normalizedFactSHA256: String
    let intrinsicSourceFrameLFSHA256: String?
    let sourceFrameNodeID: String?
    let visibleOrdinal: Int
}

private struct DisposalMachineOverlayEdgeRow: Sendable {
    let id: String
    let from: String
    let to: String
    let role: String
}

private struct DisposalMachineMerkleLeafRow: Sendable {
    let stateID: String
    let ordinal: Int
    let witnessID: String
    let normalizedLeafSHA256: String
}

private struct DisposalMachineOverlay: Sendable {
    let states: [DisposalMachineStateRow]
    let transitions: [DisposalMachineTransitionRow]
    let witnesses: [DisposalMachineWitnessRow]
    let edges: [DisposalMachineOverlayEdgeRow]
    let merkleLeaves: [DisposalMachineMerkleLeafRow]
}

private func disposalMachineID(_ domain: String, _ components: [String]) -> String {
    var data = Data("ERGENTICS_MACHINE_ID_V1".utf8)
    func appendUInt64(_ value: UInt64) {
        for shift in stride(from: 56, through: 0, by: -8) {
            data.append(UInt8((value >> UInt64(shift)) & 0xff))
        }
    }
    func appendField(_ value: String) {
        let bytes = Data(value.utf8)
        appendUInt64(UInt64(bytes.count))
        data.append(bytes)
    }
    appendField(domain)
    appendUInt64(UInt64(components.count))
    for component in components { appendField(component) }
    return disposalSHA256(data)
}

private func disposalLatticeObject(
    _ value: DisposalJSONValue,
    _ code: String
) throws -> [String: DisposalJSONValue] {
    guard case .object(let members, _) = value else {
        throw DisposalProjectionRejection(code: code)
    }
    return Dictionary(uniqueKeysWithValues: members.map { ($0.key, $0.value) })
}

private func disposalLatticeStrings(
    _ value: DisposalJSONValue?,
    _ code: String
) throws -> [String] {
    guard let value, case .array(let values, _) = value else {
        throw DisposalProjectionRejection(code: code)
    }
    return try values.map {
        guard let string = $0.stringValue() else {
            throw DisposalProjectionRejection(code: code)
        }
        return string
    }
}

private func disposalValidatedLattice(
    expectedSHA256: String
) throws -> [DisposalLatticeRule] {
    let resource = try disposalResourceData("disposal-lattice.v1", extension: "json")
    try disposalRequireProjection(resource.last == 0x0a, "GRAPH_LATTICE_LF")
    try disposalRequireProjection(
        disposalSHA256(resource) == expectedSHA256,
        "GRAPH_LATTICE_SHA256")
    let body = Data(resource.dropLast())
    var parser = DisposalCanonicalJSONParser(
        data: body,
        frameOrdinal: 0,
        journalByteOffset: 0)
    let rootValue = try parser.parse()
    try disposalRequireProjection(
        rootValue.canonicalData() == body,
        "GRAPH_LATTICE_CANONICAL")
    let root = try disposalLatticeObject(rootValue, "GRAPH_LATTICE_OBJECT")
    try disposalRequireProjection(
        Set(root.keys) == Set([
            "authority_vector", "evaluation", "reserved_unreachable_rules", "rules", "schema",
            "states", "status",
        ]),
        "GRAPH_LATTICE_KEYS")
    try disposalRequireProjection(
        root["schema"]?.stringValue() == "ergentics_disposal_projection_lattice_v1" &&
            root["authority_vector"]?.stringValue() == "00000000" &&
            root["status"]?.stringValue() == "NONAUTHORITATIVE_NO_GATE_E_PROMOTION",
        "GRAPH_LATTICE_POLICY")

    let evaluation = try disposalLatticeObject(
        root["evaluation"] ?? .null(.init(lowerBound: 0, upperBound: 0)),
        "GRAPH_LATTICE_EVALUATION")
    try disposalRequireProjection(
        Set(evaluation.keys) == Set(["default", "order", "strategy"]) &&
            evaluation["default"]?.stringValue() == "ABSTAIN_INCOMPLETE" &&
            evaluation["strategy"]?.stringValue() ==
                "FIRST_MATCH_EXACT_RELATIONAL_PREDICATES_ONLY",
        "GRAPH_LATTICE_STRATEGY")
    let order = try disposalLatticeStrings(evaluation["order"], "GRAPH_LATTICE_ORDER")
    let expectedOrder = ["D00", "D30", "D70", "D60", "D50", "D20", "D10", "D80"]
    try disposalRequireProjection(order == expectedOrder, "GRAPH_LATTICE_ORDER")

    guard let reservedValue = root["reserved_unreachable_rules"],
          case .array(let reservedValues, _) = reservedValue,
          reservedValues.count == 1
    else {
        throw DisposalProjectionRejection(code: "GRAPH_LATTICE_RESERVED_RULES")
    }
    let reserved = try disposalLatticeObject(
        reservedValues[0], "GRAPH_LATTICE_RESERVED_RULE")
    try disposalRequireProjection(
        Set(reserved.keys) == Set([
            "all", "extractor_invariant", "first_match_invariant", "output", "rule_id",
            "unreachable_proof",
        ]) &&
            reserved["rule_id"]?.stringValue() == "D40" &&
            (try disposalLatticeStrings(reserved["all"], "GRAPH_LATTICE_RESERVED_CLAUSES")) == [
                "returned_signal_count>0", "complete_conservation_count=0",
                "entered_signal_without_complete_conservation=false",
            ] &&
            reserved["output"]?.stringValue() == "CALL_RETURNED_NO_CONSERVATION" &&
            reserved["extractor_invariant"]?.stringValue() ==
                "SIGNAL_RETURNED_IFF_ENTRY_ENTERED" &&
            reserved["first_match_invariant"]?.stringValue() == "D30_PRECEDES_D40" &&
            reserved["unreachable_proof"]?.stringValue() ==
                "NO_COMPLETE_IMPLIES_D30_TRUE;COMPLETE_IMPLIES_D40_COMPLETE_COUNT_ZERO_FALSE",
        "GRAPH_LATTICE_RESERVED_RULE")

    guard let ruleValues = root["rules"], case .array(let rawRules, _) = ruleValues else {
        throw DisposalProjectionRejection(code: "GRAPH_LATTICE_RULES")
    }
    var rulesByID: [String: DisposalLatticeRule] = [:]
    for rawRule in rawRules {
        let object = try disposalLatticeObject(rawRule, "GRAPH_LATTICE_RULE")
        try disposalRequireProjection(
            Set(object.keys) == Set(["all", "output", "rule_id"]),
            "GRAPH_LATTICE_RULE_KEYS")
        guard let id = object["rule_id"]?.stringValue(),
              let output = object["output"]?.stringValue()
        else {
            throw DisposalProjectionRejection(code: "GRAPH_LATTICE_RULE_FIELDS")
        }
        let clauses = try disposalLatticeStrings(object["all"], "GRAPH_LATTICE_CLAUSES")
        try disposalRequireProjection(rulesByID[id] == nil, "GRAPH_LATTICE_RULE_DUPLICATE")
        rulesByID[id] = .init(id: id, clauses: clauses, output: output)
    }
    let expected: [String: ([String], String)] = [
        "D00": (["input_set_admitted=false"], "EMPTY"),
        "D10": (["input_set_admitted=true", "preflight_snapshot_count>0", "commitment_count=0", "terminal_count=0"], "PREFLIGHT_ONLY"),
        "D20": (["commitment_count>signal_result_count"], "COMMITMENT_RECORDED_MAY_HAVE_ENTERED"),
        "D30": (["entered_signal_without_complete_conservation=true"], "CONTAINMENT_REQUIRED"),
        "D50": (["actuation_obligation_count>0", "exact_preconservation_obligation_set_commitment=true", "all_committed_obligations_conserved=true", "terminal_count=0"], "CONSERVATION_RECORDED"),
        "D60": (["actuation_obligation_count>0", "exact_preconservation_obligation_set_commitment=true", "all_committed_obligations_conserved=true", "exact_terminal_count=1"], "TERMINAL_RECORDED"),
        "D70": (["preactuation_rejection_terminal_count=1", "entered_signal_count=0"], "REJECTED"),
        "D80": (["input_set_admitted=true"], "ABSTAIN_INCOMPLETE"),
    ]
    try disposalRequireProjection(Set(rulesByID.keys) == Set(expected.keys), "GRAPH_LATTICE_RULE_SET")
    for (id, expectedRule) in expected {
        guard let observed = rulesByID[id] else {
            throw DisposalProjectionRejection(code: "GRAPH_LATTICE_RULE_MISSING", detail: id)
        }
        try disposalRequireProjection(
            observed.clauses == expectedRule.0 && observed.output == expectedRule.1,
            "GRAPH_LATTICE_RULE_MISMATCH",
            detail: id)
    }
    let expectedStates = [
        "EMPTY", "ABSTAIN_INCOMPLETE", "PREFLIGHT_ONLY",
        "COMMITMENT_RECORDED_MAY_HAVE_ENTERED", "CONTAINMENT_REQUIRED",
        "CONSERVATION_RECORDED", "TERMINAL_RECORDED",
        "REJECTED",
    ]
    try disposalRequireProjection(
        try disposalLatticeStrings(root["states"], "GRAPH_LATTICE_STATES") == expectedStates,
        "GRAPH_LATTICE_STATES")
    return try order.map {
        guard let rule = rulesByID[$0] else {
            throw DisposalProjectionRejection(code: "GRAPH_LATTICE_ORDER_JOIN", detail: $0)
        }
        return rule
    }
}

private struct DisposalLatticeInputs: Sendable {
    let inputSetAdmitted: Bool
    let operationalValuesKnown: Bool
    let predicateKnowledge: [String: Bool]
    let preflightSnapshotCount: Int
    let commitmentCount: Int
    let signalResultCount: Int
    let enteredSignalWithoutCompleteConservation: Bool?
    let exactPreconservationObligationSetCommitment: Bool?
    let allCommittedObligationsConserved: Bool?
    let terminalCount: Int
    let exactTerminalCount: Int
    let preactuationRejectionTerminalCount: Int
    let enteredSignalCount: Int
    let sources: [String: [String]]
}

private func disposalStableSetSHA256(
    domain: String,
    values: [String]
) -> String {
    disposalMachineID(domain, values.sorted())
}

private func disposalLatticePredicate(
    ordinal: Int,
    ruleOrdinal: Int,
    ruleID: String,
    clauseOrdinal: Int,
    clause: String,
    inputs: DisposalLatticeInputs
) throws -> DisposalLatticePredicate {
    let lhs: String
    let comparisonOperator: String
    let rhs: String
    let actualScalar: String
    let result: Bool?
    let sourceKey: String
    func known(_ key: String) -> Bool {
        inputs.operationalValuesKnown && (inputs.predicateKnowledge[key] ?? false)
    }

    switch clause {
    case "input_set_admitted=false":
        (lhs, comparisonOperator, rhs) = ("input_set_admitted", "=", "false")
        actualScalar = inputs.inputSetAdmitted ? "true" : "false"
        result = !inputs.inputSetAdmitted
        sourceKey = "input_set_admitted"
    case "input_set_admitted=true":
        (lhs, comparisonOperator, rhs) = ("input_set_admitted", "=", "true")
        actualScalar = inputs.inputSetAdmitted ? "true" : "false"
        result = inputs.inputSetAdmitted
        sourceKey = "input_set_admitted"
    case "preflight_snapshot_count>0":
        (lhs, comparisonOperator, rhs) = ("preflight_snapshot_count", ">", "0")
        actualScalar = known("preflight_snapshot_count")
            ? String(inputs.preflightSnapshotCount) : "UNKNOWN"
        result = known("preflight_snapshot_count") ? inputs.preflightSnapshotCount > 0 : nil
        sourceKey = "preflight_snapshot_count"
    case "commitment_count=0":
        (lhs, comparisonOperator, rhs) = ("commitment_count", "=", "0")
        actualScalar = known("commitment_count") ? String(inputs.commitmentCount) : "UNKNOWN"
        result = known("commitment_count") ? inputs.commitmentCount == 0 : nil
        sourceKey = "commitment_count"
    case "commitment_count>signal_result_count":
        (lhs, comparisonOperator, rhs) =
            ("commitment_count", ">", "signal_result_count")
        actualScalar = known("commitment_vs_signal_result")
            ? "\(inputs.commitmentCount)>\(inputs.signalResultCount)" : "UNKNOWN"
        result = known("commitment_vs_signal_result")
            ? inputs.commitmentCount > inputs.signalResultCount : nil
        sourceKey = "commitment_vs_signal_result"
    case "entered_signal_without_complete_conservation=true":
        (lhs, comparisonOperator, rhs) =
            ("entered_signal_without_complete_conservation", "=", "true")
        actualScalar = known("entered_signal_without_complete_conservation")
            ? inputs.enteredSignalWithoutCompleteConservation.map { $0 ? "true" : "false" }
                ?? "UNKNOWN"
            : "UNKNOWN"
        result = known("entered_signal_without_complete_conservation")
            ? inputs.enteredSignalWithoutCompleteConservation : nil
        sourceKey = "entered_signal_without_complete_conservation"
    case "actuation_obligation_count>0":
        (lhs, comparisonOperator, rhs) = ("actuation_obligation_count", ">", "0")
        actualScalar = known("actuation_obligation_count")
            ? String(inputs.commitmentCount) : "UNKNOWN"
        result = known("actuation_obligation_count") ? inputs.commitmentCount > 0 : nil
        sourceKey = "actuation_obligation_count"
    case "exact_preconservation_obligation_set_commitment=true":
        (lhs, comparisonOperator, rhs) =
            ("exact_preconservation_obligation_set_commitment", "=", "true")
        actualScalar = known("exact_preconservation_obligation_set_commitment")
            ? inputs.exactPreconservationObligationSetCommitment.map { $0 ? "true" : "false" }
                ?? "UNKNOWN"
            : "UNKNOWN"
        result = known("exact_preconservation_obligation_set_commitment")
            ? inputs.exactPreconservationObligationSetCommitment : nil
        sourceKey = "exact_preconservation_obligation_set_commitment"
    case "all_committed_obligations_conserved=true":
        (lhs, comparisonOperator, rhs) =
            ("all_committed_obligations_conserved", "=", "true")
        actualScalar = known("all_committed_obligations_conserved")
            ? inputs.allCommittedObligationsConserved.map { $0 ? "true" : "false" }
                ?? "UNKNOWN"
            : "UNKNOWN"
        result = known("all_committed_obligations_conserved")
            ? inputs.allCommittedObligationsConserved : nil
        sourceKey = "all_committed_obligations_conserved"
    case "terminal_count=0":
        (lhs, comparisonOperator, rhs) = ("terminal_count", "=", "0")
        actualScalar = known("terminal_count") ? String(inputs.terminalCount) : "UNKNOWN"
        result = known("terminal_count") ? inputs.terminalCount == 0 : nil
        sourceKey = "terminal_count"
    case "exact_terminal_count=1":
        (lhs, comparisonOperator, rhs) = ("exact_terminal_count", "=", "1")
        actualScalar = known("exact_terminal_count")
            ? String(inputs.exactTerminalCount) : "UNKNOWN"
        result = known("exact_terminal_count") ? inputs.exactTerminalCount == 1 : nil
        sourceKey = "exact_terminal_count"
    case "preactuation_rejection_terminal_count=1":
        (lhs, comparisonOperator, rhs) =
            ("preactuation_rejection_terminal_count", "=", "1")
        actualScalar = known("preactuation_rejection_terminal_count")
            ? String(inputs.preactuationRejectionTerminalCount) : "UNKNOWN"
        result = known("preactuation_rejection_terminal_count")
            ? inputs.preactuationRejectionTerminalCount == 1 : nil
        sourceKey = "preactuation_rejection_terminal_count"
    case "entered_signal_count=0":
        (lhs, comparisonOperator, rhs) = ("entered_signal_count", "=", "0")
        actualScalar = known("entered_signal_count")
            ? String(inputs.enteredSignalCount) : "UNKNOWN"
        result = known("entered_signal_count") ? inputs.enteredSignalCount == 0 : nil
        sourceKey = "entered_signal_count"
    default:
        throw DisposalProjectionRejection(
            code: "GRAPH_LATTICE_UNKNOWN_PREDICATE",
            detail: clause)
    }

    let sourceValues = Array(Set(inputs.sources[sourceKey] ?? [])).sorted()
    let sourceSetSHA256 = disposalStableSetSHA256(
        domain: "disposal-lattice-predicate-source-set-v1",
        values: sourceValues)
    let normalizedState = result.map { $0 ? "TRUE" : "FALSE" } ?? "UNKNOWN"
    let predicateSHA256 = disposalMachineID(
        "disposal-lattice-predicate-v1",
        [
            String(ordinal), String(ruleOrdinal), ruleID, String(clauseOrdinal),
            clause, lhs, comparisonOperator, rhs, actualScalar,
            normalizedState, String(sourceValues.count), sourceSetSHA256,
        ])
    return .init(
        ordinal: ordinal,
        ruleOrdinal: ruleOrdinal,
        ruleID: ruleID,
        clauseOrdinal: clauseOrdinal,
        clause: clause,
        lhs: lhs,
        comparisonOperator: comparisonOperator,
        rhs: rhs,
        actualScalar: actualScalar,
        normalizedState: normalizedState,
        sourceCount: sourceValues.count,
        sourceSetSHA256: sourceSetSHA256,
        predicateSHA256: predicateSHA256)
}

private func disposalEvaluateLattice(
    rules: [DisposalLatticeRule],
    inputs: DisposalLatticeInputs
) throws -> DisposalLatticeDecision {
    var predicates: [DisposalLatticePredicate] = []
    var firstPredicateByClause: [String: DisposalLatticePredicate] = [:]
    for (ruleOrdinal, rule) in rules.enumerated() {
        for (clauseOrdinal, clause) in rule.clauses.enumerated() {
            let predicate = try disposalLatticePredicate(
                ordinal: predicates.count,
                ruleOrdinal: ruleOrdinal,
                ruleID: rule.id,
                clauseOrdinal: clauseOrdinal,
                clause: clause,
                inputs: inputs)
            predicates.append(predicate)
            if firstPredicateByClause[clause] == nil {
                firstPredicateByClause[clause] = predicate
            }
        }
    }
    guard let matched = rules.first(where: { rule in
        rule.clauses.allSatisfy {
            firstPredicateByClause[$0]?.normalizedState == "TRUE"
        }
    }) else {
        throw DisposalProjectionRejection(code: "GRAPH_LATTICE_NO_MATCH")
    }
    let vectorSHA256 = disposalMachineID(
        "disposal-lattice-ordered-predicate-vector-v1",
        predicates.map(\.predicateSHA256))
    return .init(
        ruleID: matched.id,
        stateClass: matched.output,
        predicates: predicates,
        predicateVectorSHA256: vectorSHA256)
}

struct DisposalGraphLatticeTestInput: Sendable {
    var inputSetAdmitted = true
    var preflightSnapshotCount = 0
    var commitmentCount = 0
    var signalResultCount = 0
    var enteredSignalWithoutCompleteConservation: Bool? = false
    var exactPreconservationObligationSetCommitment: Bool? = nil
    var allCommittedObligationsConserved: Bool? = nil
    var terminalCount = 0
    var exactTerminalCount = 0
    var preactuationRejectionTerminalCount = 0
    var enteredSignalCount = 0
}

func disposalGraphEvaluateForTesting(
    _ input: DisposalGraphLatticeTestInput
) throws -> (ruleID: String, stateClass: String, predicateVectorSHA256: String) {
    let lattice = try disposalResourceData("disposal-lattice.v1", extension: "json")
    let rules = try disposalValidatedLattice(expectedSHA256: disposalSHA256(lattice))
    let keys = [
        "preflight_snapshot_count", "commitment_count", "actuation_obligation_count",
        "commitment_vs_signal_result", "entered_signal_without_complete_conservation",
        "exact_preconservation_obligation_set_commitment",
        "all_committed_obligations_conserved", "terminal_count", "exact_terminal_count",
        "preactuation_rejection_terminal_count", "entered_signal_count",
    ]
    let decision = try disposalEvaluateLattice(
        rules: rules,
        inputs: .init(
            inputSetAdmitted: input.inputSetAdmitted,
            operationalValuesKnown: true,
            predicateKnowledge: Dictionary(uniqueKeysWithValues: keys.map { ($0, true) }),
            preflightSnapshotCount: input.preflightSnapshotCount,
            commitmentCount: input.commitmentCount,
            signalResultCount: input.signalResultCount,
            enteredSignalWithoutCompleteConservation:
                input.enteredSignalWithoutCompleteConservation,
            exactPreconservationObligationSetCommitment:
                input.exactPreconservationObligationSetCommitment,
            allCommittedObligationsConserved: input.allCommittedObligationsConserved,
            terminalCount: input.terminalCount,
            exactTerminalCount: input.exactTerminalCount,
            preactuationRejectionTerminalCount: input.preactuationRejectionTerminalCount,
            enteredSignalCount: input.enteredSignalCount,
            sources: [:]))
    return (decision.ruleID, decision.stateClass, decision.predicateVectorSHA256)
}

func disposalMachineIDForTesting(_ domain: String, _ components: [String]) -> String {
    disposalMachineID(domain, components)
}

private func disposalExactRowSHA256(
    table: String,
    columns: [String],
    values: [String?]
) throws -> String {
    try disposalRequireProjection(columns.count == values.count, "GRAPH_WITNESS_ROW_SHAPE")
    var fields = [table]
    for (column, value) in zip(columns, values) {
        fields.append(column)
        if let value {
            fields.append("VALUE:\(value.utf8.count):\(value)")
        } else {
            fields.append("NULL")
        }
    }
    return disposalMachineID("disposal-exact-typed-row-v1", fields)
}

private func disposalNormalizedFactSHA256(
    table: String,
    values: [String]
) -> String {
    disposalMachineID("disposal-normalized-typed-fact-v1", [table] + values)
}

private func disposalMachineFacts(
    journal: DisposalDecodedJournal,
    evidence: DisposalEvidenceMaterial
) throws -> [DisposalMachineFact] {
    let database = try DisposalSQLiteConnection(serializedReadOnly: evidence.database)
    defer { try? database.close() }
    let frameOrdinalByID = Dictionary(
        uniqueKeysWithValues: evidence.frameIDs.enumerated().map { ($0.element, $0.offset) })
    let frameHashByID = Dictionary(
        uniqueKeysWithValues: zip(
            evidence.frameIDs,
            journal.frames.map(\.rawWithLFSHA256)))
    var facts: [DisposalMachineFact] = []

    func rows(_ sql: String, columns: Int) throws -> [[String?]] {
        let statement = try database.prepare(sql)
        var result: [[String?]] = []
        while try statement.step() {
            result.append((0..<columns).map { statement.optionalText(Int32($0)) })
        }
        return result
    }

    func required(_ row: [String?], _ index: Int, _ code: String) throws -> String {
        guard let value = row[index] else {
            throw DisposalProjectionRejection(code: code)
        }
        return value
    }

    func sourceOrdinal(_ frameID: String, _ code: String) throws -> Int {
        guard let ordinal = frameOrdinalByID[frameID] else {
            throw DisposalProjectionRejection(code: code, detail: frameID)
        }
        return ordinal
    }

    func sourceHash(_ frameID: String, _ code: String) throws -> String {
        guard let hash = frameHashByID[frameID] else {
            throw DisposalProjectionRejection(code: code, detail: frameID)
        }
        return hash
    }

    let targetColumns = [
        "target_id", "invocation_id", "target_role", "numeric_pid", "target_form",
        "expected_uniqueid_text", "expected_idversion_text", "expected_parent_uniqueid_text",
        "expected_parent_idversion_text", "expected_sid", "expected_pgid", "expected_uuid_hex",
        "expected_uid", "expected_gid", "expected_image_artifact_id",
        "expected_cwd_artifact_id",
    ]
    var targetKeys: [String: String] = [:]
    for row in try rows(
        "SELECT " + targetColumns.map { "t." + $0 }.joined(separator: ",") +
            ",p.first_source_frame_id,p.first_source_ordinal FROM targets t " +
            "JOIN target_provenance p ON p.target_id=t.target_id ORDER BY t.target_id",
        columns: targetColumns.count + 2)
    {
        let rowID = try required(row, 0, "GRAPH_MACHINE_TARGET_ID")
        try disposalRequireProjection(
            try required(row, 1, "GRAPH_MACHINE_TARGET_INVOCATION") == evidence.invocationID,
            "GRAPH_MACHINE_TARGET_INVOCATION")
        let stableValues = [
            try required(row, 2, "GRAPH_MACHINE_TARGET_ROLE"),
            try required(row, 3, "GRAPH_MACHINE_TARGET_PID"),
            try required(row, 4, "GRAPH_MACHINE_TARGET_FORM"),
        ] + row[5...13].map { $0 ?? "NULL" }
        let provenanceFrameID = try required(row, 16, "GRAPH_MACHINE_TARGET_PROVENANCE_FRAME")
        let provenanceOrdinalText = try required(row, 17, "GRAPH_MACHINE_TARGET_PROVENANCE_ORDINAL")
        guard let provenanceOrdinal = Int(provenanceOrdinalText) else {
            throw DisposalProjectionRejection(code: "GRAPH_MACHINE_TARGET_PROVENANCE_ORDINAL")
        }
        try disposalRequireProjection(
            try sourceOrdinal(provenanceFrameID, "GRAPH_MACHINE_TARGET_PROVENANCE_JOIN") ==
                provenanceOrdinal,
            "GRAPH_MACHINE_TARGET_PROVENANCE_JOIN")
        let provenanceFrameHash = try sourceHash(
            provenanceFrameID, "GRAPH_MACHINE_TARGET_PROVENANCE_HASH")
        let normalized = disposalNormalizedFactSHA256(
            table: "targets", values: [provenanceFrameHash] + stableValues)
        targetKeys[rowID] = normalized
        facts.append(.init(
            table: "targets",
            rowID: rowID,
            sourceFrameID: provenanceFrameID,
            visibleOrdinal: provenanceOrdinal,
            incomplete: false,
            exactRowSHA256: try disposalExactRowSHA256(
                table: "targets", columns: targetColumns,
                values: Array(row.prefix(targetColumns.count))),
            normalizedFactSHA256: normalized,
            attributes: [
                "target_key": normalized,
                "target_role": try required(row, 2, "GRAPH_MACHINE_TARGET_ROLE"),
                "numeric_pid": try required(row, 3, "GRAPH_MACHINE_TARGET_PID"),
                "target_form": try required(row, 4, "GRAPH_MACHINE_TARGET_FORM"),
                "expected_uniqueid_text": row[5] ?? "",
                "expected_idversion_text": row[6] ?? "",
            ]))
        let provenanceColumns = ["target_id", "first_source_frame_id", "first_source_ordinal"]
        let provenanceValues: [String?] = [rowID, provenanceFrameID, provenanceOrdinalText]
        let provenanceNormalized = disposalNormalizedFactSHA256(
            table: "target_provenance",
            values: [normalized, provenanceFrameHash, provenanceOrdinalText])
        facts.append(.init(
            table: "target_provenance",
            rowID: rowID,
            sourceFrameID: provenanceFrameID,
            visibleOrdinal: provenanceOrdinal,
            incomplete: false,
            exactRowSHA256: try disposalExactRowSHA256(
                table: "target_provenance", columns: provenanceColumns,
                values: provenanceValues),
            normalizedFactSHA256: provenanceNormalized,
            attributes: [:]))
    }

    let snapshotColumns = [
        "snapshot_id", "source_frame_id", "target_id", "snapshot_phase", "snapshot_kind",
        "receipt_id", "image_join_id", "cwd_join_id", "group_snapshot_id",
        "session_snapshot_id", "snapshot_sha256",
    ]
    for row in try rows(
        "SELECT " + snapshotColumns.joined(separator: ",") +
            " FROM target_snapshots ORDER BY snapshot_id",
        columns: snapshotColumns.count)
    {
        let rowID = try required(row, 0, "GRAPH_MACHINE_SNAPSHOT_ID")
        let frameID = try required(row, 1, "GRAPH_MACHINE_SNAPSHOT_FRAME")
        let targetID = try required(row, 2, "GRAPH_MACHINE_SNAPSHOT_TARGET")
        guard let targetKey = targetKeys[targetID] else {
            throw DisposalProjectionRejection(code: "GRAPH_MACHINE_SNAPSHOT_TARGET_JOIN")
        }
        let phase = try required(row, 3, "GRAPH_MACHINE_SNAPSHOT_PHASE")
        let kind = try required(row, 4, "GRAPH_MACHINE_SNAPSHOT_KIND")
        let normalized = disposalNormalizedFactSHA256(
            table: "target_snapshots",
            values: [try sourceHash(frameID, "GRAPH_MACHINE_SNAPSHOT_FRAME_HASH"),
                     targetKey, phase, kind, try required(row, 10, "GRAPH_MACHINE_SNAPSHOT_SHA")])
        facts.append(.init(
            table: "target_snapshots", rowID: rowID, sourceFrameID: frameID,
            visibleOrdinal: try sourceOrdinal(frameID, "GRAPH_MACHINE_SNAPSHOT_ORDINAL"),
            incomplete: false,
            exactRowSHA256: try disposalExactRowSHA256(
                table: "target_snapshots", columns: snapshotColumns, values: row),
            normalizedFactSHA256: normalized,
            attributes: ["target_key": targetKey, "snapshot_phase": phase]))
    }

    let commitmentColumns = [
        "commitment_id", "source_frame_id", "target_id", "operation", "target_form",
        "numeric_argument", "signal_number", "prestate_pair_id", "prestate_sha256",
        "budget_ordinal", "call_may_enter_after_record",
        "missing_result_means_may_have_entered", "retry_authorized",
        "atomic_generation_bound_signal_available",
    ]
    var commitmentFacts: [String: DisposalMachineFact] = [:]
    let targetFactsByID = Dictionary(
        uniqueKeysWithValues: facts.filter { $0.table == "targets" }.map { ($0.rowID, $0) })
    for row in try rows(
        "SELECT " + commitmentColumns.joined(separator: ",") +
            " FROM commitments ORDER BY commitment_id",
        columns: commitmentColumns.count)
    {
        let rowID = try required(row, 0, "GRAPH_MACHINE_COMMITMENT_ID")
        let frameID = try required(row, 1, "GRAPH_MACHINE_COMMITMENT_FRAME")
        let targetID = try required(row, 2, "GRAPH_MACHINE_COMMITMENT_TARGET")
        guard let targetKey = targetKeys[targetID] else {
            throw DisposalProjectionRejection(code: "GRAPH_MACHINE_COMMITMENT_TARGET_JOIN")
        }
        let normalized = disposalNormalizedFactSHA256(
            table: "commitments",
            values: [try sourceHash(frameID, "GRAPH_MACHINE_COMMITMENT_FRAME_HASH"), targetKey] +
                row[3...6].map { $0 ?? "NULL" } +
                [try required(row, 8, "GRAPH_MACHINE_COMMITMENT_PRESTATE_SHA")] +
                row[9...13].map { $0 ?? "NULL" })
        var commitmentAttributes = ["target_key": targetKey]
        if let target = targetFactsByID[targetID],
           let targetRole = target.attributes["target_role"],
           let targetForm = target.attributes["target_form"],
           let targetPIDText = target.attributes["numeric_pid"],
           let targetPID = Int(targetPIDText),
           let targetUniqueText = target.attributes["expected_uniqueid_text"],
           let targetUnique = UInt64(targetUniqueText),
           let targetVersionText = target.attributes["expected_idversion_text"],
           let targetVersion = UInt64(targetVersionText),
           let numericArgumentText = row[5], let numericArgument = Int(numericArgumentText),
           let signalNumberText = row[6], let signalNumber = Int(signalNumberText),
           let budgetOrdinalText = row[9], let budgetOrdinal = Int(budgetOrdinalText)
        {
            commitmentAttributes["obligation_key_sha256"] =
                DisposalConservationSetMerkle.obligationKey(
                    commitmentFrameLFSHA256: try sourceHash(
                        frameID, "GRAPH_MACHINE_COMMITMENT_OBLIGATION_FRAME_HASH"),
                    targetRole: targetRole,
                    targetForm: targetForm,
                    targetPID: targetPID,
                    targetUniqueID: targetUnique,
                    targetIDVersion: targetVersion,
                    operation: try required(row, 3, "GRAPH_MACHINE_COMMITMENT_OPERATION"),
                    numericArgument: numericArgument,
                    signalNumber: signalNumber,
                    budgetOrdinal: budgetOrdinal)
        }
        let fact = DisposalMachineFact(
            table: "commitments", rowID: rowID, sourceFrameID: frameID,
            visibleOrdinal: try sourceOrdinal(frameID, "GRAPH_MACHINE_COMMITMENT_ORDINAL"),
            incomplete: false,
            exactRowSHA256: try disposalExactRowSHA256(
                table: "commitments", columns: commitmentColumns, values: row),
            normalizedFactSHA256: normalized,
            attributes: commitmentAttributes)
        facts.append(fact)
        commitmentFacts[rowID] = fact
    }

    let signalColumns = [
        "signal_call_id", "commitment_id", "source_frame_id", "postcommit_pair_id",
        "entry_state", "return_state", "numeric_argument", "signal_number",
        "certificate_age_ns_text", "certificate_max_age_ns_text", "return_value",
        "errno_value", "delivery_class", "retried",
    ]
    for row in try rows(
        "SELECT " + signalColumns.joined(separator: ",") +
            " FROM signal_calls ORDER BY signal_call_id",
        columns: signalColumns.count)
    {
        let rowID = try required(row, 0, "GRAPH_MACHINE_SIGNAL_ID")
        let commitmentID = try required(row, 1, "GRAPH_MACHINE_SIGNAL_COMMITMENT")
        guard let commitment = commitmentFacts[commitmentID],
              let targetKey = commitment.attributes["target_key"]
        else {
            throw DisposalProjectionRejection(code: "GRAPH_MACHINE_SIGNAL_COMMITMENT_JOIN")
        }
        let frameID = row[2]
        let anchoredOrdinal: Int
        let stableFrameHash: String
        let incomplete: Bool
        if let frameID {
            anchoredOrdinal = try sourceOrdinal(frameID, "GRAPH_MACHINE_SIGNAL_ORDINAL")
            stableFrameHash = try sourceHash(frameID, "GRAPH_MACHINE_SIGNAL_FRAME_HASH")
            incomplete = false
        } else {
            anchoredOrdinal = commitment.visibleOrdinal
            stableFrameHash = "UNPLACED_SOURCE_FRAME"
            incomplete = true
        }
        let normalized = disposalNormalizedFactSHA256(
            table: "signal_calls",
            values: [stableFrameHash, commitment.normalizedFactSHA256, targetKey] +
                row[4...13].map { $0 ?? "NULL" })
        facts.append(.init(
            table: "signal_calls", rowID: rowID,
            sourceFrameID: frameID ?? commitment.sourceFrameID,
            visibleOrdinal: anchoredOrdinal, incomplete: incomplete,
            exactRowSHA256: try disposalExactRowSHA256(
                table: "signal_calls", columns: signalColumns, values: row),
            normalizedFactSHA256: normalized,
            attributes: [
                "target_key": targetKey,
                "entry_state": try required(row, 4, "GRAPH_MACHINE_SIGNAL_ENTRY"),
                "return_state": try required(row, 5, "GRAPH_MACHINE_SIGNAL_RETURN"),
            ]))
    }

    let conservationColumns = [
        "conservation_id", "source_frame_id", "target_id", "absence_proof_id", "reap_id",
        "conservation_basis", "exact_reap_required", "exact_reap_satisfied",
        "generation_absent", "group_empty", "session_empty", "two_signal_zero_esrch",
        "completion_state",
    ]
    for row in try rows(
        "SELECT " + conservationColumns.joined(separator: ",") +
            " FROM conservations ORDER BY conservation_id",
        columns: conservationColumns.count)
    {
        let rowID = try required(row, 0, "GRAPH_MACHINE_CONSERVATION_ID")
        let frameID = try required(row, 1, "GRAPH_MACHINE_CONSERVATION_FRAME")
        let targetID = try required(row, 2, "GRAPH_MACHINE_CONSERVATION_TARGET")
        guard let targetKey = targetKeys[targetID] else {
            throw DisposalProjectionRejection(code: "GRAPH_MACHINE_CONSERVATION_TARGET_JOIN")
        }
        let completion = try required(row, 12, "GRAPH_MACHINE_CONSERVATION_COMPLETION")
        let normalized = disposalNormalizedFactSHA256(
            table: "conservations",
            values: [try sourceHash(frameID, "GRAPH_MACHINE_CONSERVATION_FRAME_HASH"), targetKey] +
                row[5...12].map { $0 ?? "NULL" })
        facts.append(.init(
            table: "conservations", rowID: rowID, sourceFrameID: frameID,
            visibleOrdinal: try sourceOrdinal(frameID, "GRAPH_MACHINE_CONSERVATION_ORDINAL"),
            incomplete: false,
            exactRowSHA256: try disposalExactRowSHA256(
                table: "conservations", columns: conservationColumns, values: row),
            normalizedFactSHA256: normalized,
            attributes: ["target_key": targetKey, "completion_state": completion]))
    }

    let conservationFactsByID = Dictionary(
        uniqueKeysWithValues: facts.filter { $0.table == "conservations" }.map { ($0.rowID, $0) })
    let setColumns = [
        "conservation_set_commitment_id", "source_frame_id", "invocation_id", "epoch_label",
        "purpose", "scope_kind", "scope_id", "algorithm", "domain_tag", "leaf_ordering",
        "duplicate_policy", "tree_shape", "odd_leaf_rule", "witness_root_sha256",
        "leaf_count", "temporal_state",
    ]
    var setFactsByID: [String: DisposalMachineFact] = [:]
    for row in try rows(
        "SELECT " + setColumns.joined(separator: ",") +
            " FROM conservation_set_commitments ORDER BY conservation_set_commitment_id",
        columns: setColumns.count)
    {
        let rowID = try required(row, 0, "GRAPH_MACHINE_SET_ID")
        let frameID = try required(row, 1, "GRAPH_MACHINE_SET_FRAME")
        try disposalRequireProjection(
            try required(row, 2, "GRAPH_MACHINE_SET_INVOCATION") == evidence.invocationID,
            "GRAPH_MACHINE_SET_INVOCATION")
        let normalized = disposalNormalizedFactSHA256(
            table: "conservation_set_commitments",
            values: [try sourceHash(frameID, "GRAPH_MACHINE_SET_FRAME_HASH")] +
                row[2...15].map { $0 ?? "NULL" })
        let fact = DisposalMachineFact(
            table: "conservation_set_commitments", rowID: rowID, sourceFrameID: frameID,
            visibleOrdinal: try sourceOrdinal(frameID, "GRAPH_MACHINE_SET_ORDINAL"),
            incomplete: false,
            exactRowSHA256: try disposalExactRowSHA256(
                table: "conservation_set_commitments", columns: setColumns, values: row),
            normalizedFactSHA256: normalized,
            attributes: [
                "set_id": rowID,
                "epoch_label": try required(row, 3, "GRAPH_MACHINE_SET_EPOCH"),
                "purpose": try required(row, 4, "GRAPH_MACHINE_SET_PURPOSE"),
                "scope_kind": try required(row, 5, "GRAPH_MACHINE_SET_SCOPE_KIND"),
                "scope_id": try required(row, 6, "GRAPH_MACHINE_SET_SCOPE_ID"),
                "algorithm": try required(row, 7, "GRAPH_MACHINE_SET_ALGORITHM"),
                "domain_tag": try required(row, 8, "GRAPH_MACHINE_SET_DOMAIN"),
                "leaf_ordering": try required(row, 9, "GRAPH_MACHINE_SET_ORDER"),
                "duplicate_policy": try required(row, 10, "GRAPH_MACHINE_SET_DUPLICATE"),
                "tree_shape": try required(row, 11, "GRAPH_MACHINE_SET_SHAPE"),
                "odd_leaf_rule": try required(row, 12, "GRAPH_MACHINE_SET_ODD"),
                "witness_root_sha256": try required(row, 13, "GRAPH_MACHINE_SET_ROOT"),
                "leaf_count": try required(row, 14, "GRAPH_MACHINE_SET_COUNT"),
                "temporal_state": try required(row, 15, "GRAPH_MACHINE_SET_TEMPORAL"),
            ])
        facts.append(fact)
        setFactsByID[rowID] = fact
    }

    let membershipColumns = [
        "membership_id", "conservation_set_commitment_id", "leaf_ordinal",
        "obligation_key_sha256", "obligation_commitment_id", "target_id", "target_role",
        "target_form", "expected_uniqueid_text", "expected_idversion_text", "operation",
        "numeric_argument", "signal_number", "budget_ordinal", "commitment_source_frame_id",
        "commitment_frame_lf_sha256", "leaf_sha256", "proof_sha256", "proof_depth",
    ]
    var membershipFactsByID: [String: DisposalMachineFact] = [:]
    for row in try rows(
        "SELECT " + membershipColumns.joined(separator: ",") +
            " FROM conservation_set_memberships ORDER BY membership_id",
        columns: membershipColumns.count)
    {
        let rowID = try required(row, 0, "GRAPH_MACHINE_MEMBERSHIP_ID")
        let setID = try required(row, 1, "GRAPH_MACHINE_MEMBERSHIP_SET")
        guard let set = setFactsByID[setID], let frameID = set.sourceFrameID else {
            throw DisposalProjectionRejection(code: "GRAPH_MACHINE_MEMBERSHIP_SET_JOIN")
        }
        let normalized = disposalNormalizedFactSHA256(
            table: "conservation_set_memberships",
            values: [set.normalizedFactSHA256] + row[2...3].map { $0 ?? "NULL" } +
                row[6...13].map { $0 ?? "NULL" } + row[15...18].map { $0 ?? "NULL" })
        let fact = DisposalMachineFact(
            table: "conservation_set_memberships", rowID: rowID, sourceFrameID: frameID,
            visibleOrdinal: set.visibleOrdinal, incomplete: false,
            exactRowSHA256: try disposalExactRowSHA256(
                table: "conservation_set_memberships", columns: membershipColumns, values: row),
            normalizedFactSHA256: normalized,
            attributes: [
                "set_id": setID,
                "membership_id": rowID,
                "leaf_ordinal": try required(row, 2, "GRAPH_MACHINE_MEMBERSHIP_ORDINAL"),
                "obligation_key_sha256": try required(row, 3, "GRAPH_MACHINE_MEMBERSHIP_KEY"),
                "obligation_commitment_id": try required(
                    row, 4, "GRAPH_MACHINE_MEMBERSHIP_COMMITMENT"),
                "leaf_sha256": try required(row, 16, "GRAPH_MACHINE_MEMBERSHIP_LEAF"),
                "proof_sha256": try required(row, 17, "GRAPH_MACHINE_MEMBERSHIP_PROOF"),
                "proof_depth": try required(row, 18, "GRAPH_MACHINE_MEMBERSHIP_DEPTH"),
            ])
        facts.append(fact)
        membershipFactsByID[rowID] = fact
    }

    let proofColumns = ["membership_id", "proof_ordinal", "sibling_position", "sibling_sha256"]
    for row in try rows(
        "SELECT " + proofColumns.joined(separator: ",") +
            " FROM conservation_set_membership_proof_nodes " +
            "ORDER BY membership_id,proof_ordinal",
        columns: proofColumns.count)
    {
        let membershipID = try required(row, 0, "GRAPH_MACHINE_PROOF_MEMBERSHIP")
        guard let membership = membershipFactsByID[membershipID],
              let frameID = membership.sourceFrameID
        else {
            throw DisposalProjectionRejection(code: "GRAPH_MACHINE_PROOF_MEMBERSHIP_JOIN")
        }
        let proofOrdinal = try required(row, 1, "GRAPH_MACHINE_PROOF_ORDINAL")
        let rowID = membershipID + "#" + proofOrdinal
        let normalized = disposalNormalizedFactSHA256(
            table: "conservation_set_membership_proof_nodes",
            values: [membership.normalizedFactSHA256] + row[1...3].map { $0 ?? "NULL" })
        facts.append(.init(
            table: "conservation_set_membership_proof_nodes", rowID: rowID,
            sourceFrameID: frameID, visibleOrdinal: membership.visibleOrdinal,
            incomplete: false,
            exactRowSHA256: try disposalExactRowSHA256(
                table: "conservation_set_membership_proof_nodes",
                columns: proofColumns, values: row),
            normalizedFactSHA256: normalized,
            attributes: [
                "membership_id": membershipID,
                "proof_ordinal": proofOrdinal,
                "sibling_position": try required(row, 2, "GRAPH_MACHINE_PROOF_POSITION"),
                "sibling_sha256": try required(row, 3, "GRAPH_MACHINE_PROOF_SIBLING"),
            ]))
    }

    let conservationStateColumns = [
        "conservation_id", "source_frame_id", "conservation_set_commitment_id", "merkle_state",
    ]
    for row in try rows(
        "SELECT " + conservationStateColumns.joined(separator: ",") +
            " FROM conservation_set_conservation_states ORDER BY conservation_id",
        columns: conservationStateColumns.count)
    {
        let conservationID = try required(row, 0, "GRAPH_MACHINE_CONSERVATION_STATE_ID")
        guard let conservation = conservationFactsByID[conservationID] else {
            throw DisposalProjectionRejection(code: "GRAPH_MACHINE_CONSERVATION_STATE_JOIN")
        }
        let frameID = try required(row, 1, "GRAPH_MACHINE_CONSERVATION_STATE_FRAME")
        try disposalRequireProjection(
            frameID == conservation.sourceFrameID,
            "GRAPH_MACHINE_CONSERVATION_STATE_FRAME_JOIN")
        let setSemantic = row[2].flatMap { setFactsByID[$0]?.normalizedFactSHA256 }
            ?? "ABSENT_UNKNOWN"
        let normalized = disposalNormalizedFactSHA256(
            table: "conservation_set_conservation_states",
            values: [conservation.normalizedFactSHA256,
                     setSemantic,
                     try required(row, 3, "GRAPH_MACHINE_CONSERVATION_STATE")])
        facts.append(.init(
            table: "conservation_set_conservation_states", rowID: conservationID,
            sourceFrameID: frameID, visibleOrdinal: conservation.visibleOrdinal,
            incomplete: false,
            exactRowSHA256: try disposalExactRowSHA256(
                table: "conservation_set_conservation_states",
                columns: conservationStateColumns, values: row),
            normalizedFactSHA256: normalized,
            attributes: [
                "conservation_id": conservationID,
                "set_id": row[2] ?? "",
                "merkle_state": try required(row, 3, "GRAPH_MACHINE_CONSERVATION_STATE"),
            ]))
    }

    let mappingColumns = [
        "mapping_id", "conservation_id", "conservation_set_commitment_id", "membership_id",
        "target_id", "mapping_state",
    ]
    for row in try rows(
        "SELECT " + mappingColumns.joined(separator: ",") +
            " FROM conservation_set_obligation_mappings ORDER BY mapping_id",
        columns: mappingColumns.count)
    {
        let rowID = try required(row, 0, "GRAPH_MACHINE_MAPPING_ID")
        let conservationID = try required(row, 1, "GRAPH_MACHINE_MAPPING_CONSERVATION")
        let membershipID = try required(row, 3, "GRAPH_MACHINE_MAPPING_MEMBERSHIP")
        guard let conservation = conservationFactsByID[conservationID],
              let membership = membershipFactsByID[membershipID],
              let frameID = conservation.sourceFrameID
        else {
            throw DisposalProjectionRejection(code: "GRAPH_MACHINE_MAPPING_JOIN")
        }
        let normalized = disposalNormalizedFactSHA256(
            table: "conservation_set_obligation_mappings",
            values: [conservation.normalizedFactSHA256, membership.normalizedFactSHA256,
                     try required(row, 5, "GRAPH_MACHINE_MAPPING_STATE")])
        facts.append(.init(
            table: "conservation_set_obligation_mappings", rowID: rowID,
            sourceFrameID: frameID, visibleOrdinal: conservation.visibleOrdinal,
            incomplete: false,
            exactRowSHA256: try disposalExactRowSHA256(
                table: "conservation_set_obligation_mappings",
                columns: mappingColumns, values: row),
            normalizedFactSHA256: normalized,
            attributes: [
                "set_id": try required(row, 2, "GRAPH_MACHINE_MAPPING_SET"),
                "membership_id": membershipID,
                "conservation_id": conservationID,
            ]))
    }

    let terminalColumns = [
        "terminal_outcome_id", "invocation_id", "terminal_frame_id", "status_text",
        "exit_code", "capture_state", "gate_c_conservation_id",
        "guardian_conservation_id", "wrapper_conservation_id", "fixture_conservation_id",
        "completion_class", "authority_vector", "gate_e_outcome",
    ]
    for row in try rows(
        "SELECT " + terminalColumns.joined(separator: ",") +
            " FROM terminal_outcomes ORDER BY terminal_outcome_id",
        columns: terminalColumns.count)
    {
        let rowID = try required(row, 0, "GRAPH_MACHINE_TERMINAL_ID")
        try disposalRequireProjection(
            try required(row, 1, "GRAPH_MACHINE_TERMINAL_INVOCATION") == evidence.invocationID,
            "GRAPH_MACHINE_TERMINAL_INVOCATION")
        let frameID = try required(row, 2, "GRAPH_MACHINE_TERMINAL_FRAME")
        let capture = try required(row, 5, "GRAPH_MACHINE_TERMINAL_CAPTURE")
        let completion = try required(row, 10, "GRAPH_MACHINE_TERMINAL_COMPLETION")
        let normalized = disposalNormalizedFactSHA256(
            table: "terminal_outcomes",
            values: [try sourceHash(frameID, "GRAPH_MACHINE_TERMINAL_FRAME_HASH"),
                     row[4] ?? "NULL", capture, completion,
                     try required(row, 11, "GRAPH_MACHINE_TERMINAL_AUTHORITY"),
                     try required(row, 12, "GRAPH_MACHINE_TERMINAL_GATE_E")])
        facts.append(.init(
            table: "terminal_outcomes", rowID: rowID, sourceFrameID: frameID,
            visibleOrdinal: try sourceOrdinal(frameID, "GRAPH_MACHINE_TERMINAL_ORDINAL"),
            incomplete: capture == "ABSENT" || capture == "ABSTAIN",
            exactRowSHA256: try disposalExactRowSHA256(
                table: "terminal_outcomes", columns: terminalColumns, values: row),
            normalizedFactSHA256: normalized,
            attributes: ["capture_state": capture, "completion_class": completion]))
    }

    let coverageColumns = [
        "frame_id", "payload_schema", "event_type", "adapter_state", "operational_scope",
        "adapter_manifest_sha256",
    ]
    for row in try rows(
        "SELECT " + coverageColumns.joined(separator: ",") +
            " FROM frame_adapter_coverage ORDER BY frame_id",
        columns: coverageColumns.count)
    {
        let frameID = try required(row, 0, "GRAPH_MACHINE_COVERAGE_FRAME")
        let adapterState = try required(row, 3, "GRAPH_MACHINE_COVERAGE_STATE")
        let operationalScope = try required(row, 4, "GRAPH_MACHINE_COVERAGE_SCOPE")
        let normalized = disposalNormalizedFactSHA256(
            table: "frame_adapter_coverage",
            values: [try sourceHash(frameID, "GRAPH_MACHINE_COVERAGE_HASH")] +
                row[1...5].map { $0 ?? "NULL" })
        facts.append(.init(
            table: "frame_adapter_coverage", rowID: frameID, sourceFrameID: frameID,
            visibleOrdinal: try sourceOrdinal(frameID, "GRAPH_MACHINE_COVERAGE_ORDINAL"),
            incomplete: adapterState == "UNKNOWN_RAW_ONLY" && operationalScope == "LIFECYCLE",
            exactRowSHA256: try disposalExactRowSHA256(
                table: "frame_adapter_coverage", columns: coverageColumns, values: row),
            normalizedFactSHA256: normalized,
            attributes: [
                "event_type": try required(row, 2, "GRAPH_MACHINE_COVERAGE_EVENT"),
                "adapter_state": adapterState,
                "operational_scope": operationalScope,
            ]))
    }

    let missingColumns = [
        "missing_id", "invocation_id", "evidence_kind", "target_role", "source_frame_id",
        "reason_code", "value_state", "evidence_scope",
    ]
    for row in try rows(
        "SELECT " + missingColumns.joined(separator: ",") +
            " FROM missing_evidence ORDER BY missing_id",
        columns: missingColumns.count)
    {
        let rowID = try required(row, 0, "GRAPH_MACHINE_MISSING_ID")
        try disposalRequireProjection(
            try required(row, 1, "GRAPH_MACHINE_MISSING_INVOCATION") == evidence.invocationID,
            "GRAPH_MACHINE_MISSING_INVOCATION")
        let scope = try required(row, 7, "GRAPH_MACHINE_MISSING_SCOPE")
        if scope == "PROJECTION_GLOBAL_NON_PREFIX" { continue }
        let evidenceKind = try required(row, 2, "GRAPH_MACHINE_MISSING_KIND")
        let reasonCode = try required(row, 5, "GRAPH_MACHINE_MISSING_REASON")
        // This row describes the projection boundary, not evidence visible in
        // the accepted frame. A later terminal legitimately removes it, so it
        // cannot enter a prefix-content-addressed state or witness set.
        if (evidenceKind == "TERMINAL_FRAME" && reasonCode == "JOURNAL_PREFIX_NONTERMINAL") ||
            (evidenceKind == "POST_SIGNAL_CONSERVATION" &&
                reasonCode == "SIGNAL_CALL_WITHOUT_CONSERVATION_FRAME")
        {
            continue
        }
        let frameID = try required(row, 4, "GRAPH_MACHINE_MISSING_FRAME")
        let ordinal = try sourceOrdinal(frameID, "GRAPH_MACHINE_MISSING_ORDINAL")
        let normalized = disposalNormalizedFactSHA256(
            table: "missing_evidence",
            values: [try sourceHash(frameID, "GRAPH_MACHINE_MISSING_HASH")] +
                row[2...3].map { $0 ?? "NULL" } + row[5...7].map { $0 ?? "NULL" })
        facts.append(.init(
            table: "missing_evidence", rowID: rowID, sourceFrameID: frameID,
            visibleOrdinal: ordinal, incomplete: true,
            exactRowSHA256: try disposalExactRowSHA256(
                table: "missing_evidence", columns: missingColumns, values: row),
            normalizedFactSHA256: normalized,
            attributes: [
                "evidence_kind": evidenceKind,
                "reason_code": reasonCode,
            ]))
    }

    return facts.sorted {
        ($0.visibleOrdinal, $0.table, $0.normalizedFactSHA256, $0.rowID) <
            ($1.visibleOrdinal, $1.table, $1.normalizedFactSHA256, $1.rowID)
    }
}

private func disposalDerivedPostHocMerkleRoot(
    normalizedFactSHA256s: [String]
) throws -> (root: String, orderedLeaves: [String]) {
    let ordered = normalizedFactSHA256s.sorted()
    try disposalRequireProjection(
        Set(ordered).count == ordered.count,
        "GRAPH_DERIVED_POST_HOC_MERKLE_DUPLICATE")
    guard !ordered.isEmpty else {
        return (disposalMachineID("disposal-derived-post-hoc-witness-merkle-empty-v1", []), [])
    }
    let leaves = ordered.map {
        disposalMachineID("disposal-derived-post-hoc-witness-merkle-leaf-v1", [$0])
    }

    func root(_ lower: Int, _ upper: Int) -> String {
        let count = upper - lower
        if count == 1 { return leaves[lower] }
        var split = 1
        while split << 1 < count { split <<= 1 }
        return disposalMachineID(
            "disposal-derived-post-hoc-witness-merkle-node-v1",
            [root(lower, lower + split), root(lower + split, upper)])
    }
    return (root(0, leaves.count), ordered)
}

private struct DisposalTemporalMerkleQualification: Sendable {
    let exactCommitment: Bool?
    let allCommittedObligationsConserved: Bool?
    let commitmentNormalizedFactSHA256: String?
}

private func disposalTemporalMerkleQualification(
    prefixOrdinal: Int,
    facts: [DisposalMachineFact],
    sourceInvocationID: String,
    sourceEpochLabel: String
) throws -> DisposalTemporalMerkleQualification {
    let visible = facts.filter { $0.visibleOrdinal <= prefixOrdinal }
    let obligations = visible.filter { $0.table == "commitments" }
    guard !obligations.isEmpty else {
        return .init(
            exactCommitment: false,
            allCommittedObligationsConserved: false,
            commitmentNormalizedFactSHA256: nil)
    }
    let setFacts = visible.filter {
        $0.table == "conservation_set_commitments" && $0.visibleOrdinal < prefixOrdinal
    }
    guard !setFacts.isEmpty else {
        return .init(
            exactCommitment: nil,
            allCommittedObligationsConserved: nil,
            commitmentNormalizedFactSHA256: nil)
    }
    try disposalRequireProjection(setFacts.count == 1, "GRAPH_TEMPORAL_MERKLE_SET_COUNT")
    let set = setFacts[0]
    let setID = set.rowID
    guard set.attributes["purpose"] == DisposalConservationSetMerkle.purpose,
          set.attributes["scope_kind"] == DisposalConservationSetMerkle.scopeKind,
          set.attributes["scope_id"] == sourceInvocationID,
          set.attributes["epoch_label"] == sourceEpochLabel,
          set.attributes["algorithm"] == DisposalConservationSetMerkle.algorithm,
          set.attributes["domain_tag"] == DisposalConservationSetMerkle.domainTag,
          set.attributes["leaf_ordering"] == DisposalConservationSetMerkle.leafOrdering,
          set.attributes["duplicate_policy"] == DisposalConservationSetMerkle.duplicatePolicy,
          set.attributes["tree_shape"] == DisposalConservationSetMerkle.treeShape,
          set.attributes["odd_leaf_rule"] == DisposalConservationSetMerkle.oddLeafRule,
          set.attributes["temporal_state"] == "EXPLICIT_PRECONSERVATION",
          let leafCountText = set.attributes["leaf_count"],
          let leafCount = Int(leafCountText), leafCount > 0,
          let expectedRoot = set.attributes["witness_root_sha256"]
    else {
        throw DisposalProjectionRejection(code: "GRAPH_TEMPORAL_MERKLE_METADATA")
    }

    let obligationKeys = obligations.compactMap { $0.attributes["obligation_key_sha256"] }
    guard obligationKeys.count == obligations.count else {
        return .init(
            exactCommitment: nil,
            allCommittedObligationsConserved: nil,
            commitmentNormalizedFactSHA256: set.normalizedFactSHA256)
    }
    let memberships = visible.filter {
        $0.table == "conservation_set_memberships" && $0.attributes["set_id"] == setID
    }
    let membershipKeys = try memberships.map {
        guard let key = $0.attributes["obligation_key_sha256"] else {
            throw DisposalProjectionRejection(code: "GRAPH_TEMPORAL_MERKLE_MEMBERSHIP_KEY")
        }
        return key
    }
    let orderedKeys = membershipKeys.sorted()
    let hasLaterObligation = obligations.contains { $0.visibleOrdinal > set.visibleOrdinal }
    let fullSetMatches = !hasLaterObligation &&
        leafCount == obligations.count && memberships.count == leafCount &&
        Set(obligationKeys).count == obligationKeys.count &&
        Set(membershipKeys).count == membershipKeys.count &&
        Set(obligationKeys) == Set(membershipKeys)
    guard fullSetMatches else {
        return .init(
            exactCommitment: false,
            allCommittedObligationsConserved: false,
            commitmentNormalizedFactSHA256: nil)
    }

    let orderedMemberships = try memberships.sorted {
        guard let lhs = $0.attributes["leaf_ordinal"].flatMap(Int.init),
              let rhs = $1.attributes["leaf_ordinal"].flatMap(Int.init)
        else { throw DisposalProjectionRejection(code: "GRAPH_TEMPORAL_MERKLE_ORDINAL") }
        return lhs < rhs
    }
    for (ordinal, membership) in orderedMemberships.enumerated() {
        try disposalRequireProjection(
            membership.attributes["leaf_ordinal"].flatMap(Int.init) == ordinal &&
                membership.attributes["obligation_key_sha256"] == orderedKeys[ordinal] &&
                membership.attributes["leaf_sha256"] ==
                    DisposalConservationSetMerkle.leafSHA256(
                        obligationKeySHA256: orderedKeys[ordinal]),
            "GRAPH_TEMPORAL_MERKLE_LEAF_JOIN")
    }
    let derivedRoot = try DisposalConservationSetMerkle.root(
        canonicalObligationKeys: orderedKeys)
    try disposalRequireProjection(
        derivedRoot == expectedRoot,
        "GRAPH_TEMPORAL_MERKLE_ROOT")

    let proofFacts = visible.filter {
        $0.table == "conservation_set_membership_proof_nodes"
    }
    for membership in orderedMemberships {
        guard let membershipID = membership.attributes["membership_id"],
              let leafSHA256 = membership.attributes["leaf_sha256"],
              let proofDepthText = membership.attributes["proof_depth"],
              let proofDepth = Int(proofDepthText),
              let expectedProofSHA256 = membership.attributes["proof_sha256"]
        else {
            throw DisposalProjectionRejection(code: "GRAPH_TEMPORAL_MERKLE_PROOF_FIELDS")
        }
        let nodes = try proofFacts.filter {
            $0.attributes["membership_id"] == membershipID
        }.sorted {
            guard let lhs = $0.attributes["proof_ordinal"].flatMap(Int.init),
                  let rhs = $1.attributes["proof_ordinal"].flatMap(Int.init)
            else { throw DisposalProjectionRejection(code: "GRAPH_TEMPORAL_MERKLE_PROOF_ORDINAL") }
            return lhs < rhs
        }
        try disposalRequireProjection(nodes.count == proofDepth, "GRAPH_TEMPORAL_MERKLE_PROOF_DEPTH")
        var proof: [DisposalConservationMerkleProofNode] = []
        for (ordinal, node) in nodes.enumerated() {
            try disposalRequireProjection(
                node.attributes["proof_ordinal"].flatMap(Int.init) == ordinal,
                "GRAPH_TEMPORAL_MERKLE_PROOF_CONTIGUOUS")
            guard let position = node.attributes["sibling_position"],
                  let sibling = node.attributes["sibling_sha256"]
            else {
                throw DisposalProjectionRejection(code: "GRAPH_TEMPORAL_MERKLE_PROOF_NODE")
            }
            proof.append(.init(siblingPosition: position, siblingSHA256: sibling))
        }
        try disposalRequireProjection(
            DisposalConservationSetMerkle.proofSHA256(proof) == expectedProofSHA256 &&
                DisposalConservationSetMerkle.verify(
                    leafSHA256: leafSHA256, proof: proof, rootSHA256: expectedRoot),
            "GRAPH_TEMPORAL_MERKLE_PROOF_VERIFY")
    }

    let mappings = visible.filter {
        $0.table == "conservation_set_obligation_mappings" && $0.attributes["set_id"] == setID
    }
    let conservationStates = visible.filter {
        $0.table == "conservation_set_conservation_states" &&
            $0.attributes["set_id"] == setID &&
            $0.attributes["merkle_state"] == "VERIFIED_PRIOR_EXACT"
    }
    let conservationsByID = Dictionary(
        uniqueKeysWithValues: visible.filter { $0.table == "conservations" }
            .map { ($0.rowID, $0) })
    var mappedMembershipIDs: Set<String> = []
    var allMappingsComplete = mappings.count == memberships.count
    for mapping in mappings {
        guard let membershipID = mapping.attributes["membership_id"],
              let conservationID = mapping.attributes["conservation_id"],
              mappedMembershipIDs.insert(membershipID).inserted,
              membershipFactsMatch(membershipID, in: memberships),
              let conservation = conservationsByID[conservationID],
              conservation.visibleOrdinal > set.visibleOrdinal,
              conservation.attributes["completion_state"] == "COMPLETE",
              conservationStates.contains(where: {
                  $0.attributes["conservation_id"] == conservationID
              })
        else {
            allMappingsComplete = false
            continue
        }
    }
    allMappingsComplete = allMappingsComplete && mappedMembershipIDs == Set(
        memberships.compactMap { $0.attributes["membership_id"] })
    return .init(
        exactCommitment: true,
        allCommittedObligationsConserved: allMappingsComplete,
        commitmentNormalizedFactSHA256: set.normalizedFactSHA256)
}

private func membershipFactsMatch(
    _ membershipID: String,
    in memberships: [DisposalMachineFact]
) -> Bool {
    memberships.contains { $0.attributes["membership_id"] == membershipID }
}

private func disposalMachineInputs(
    prefixOrdinal: Int,
    facts: [DisposalMachineFact],
    inputSetAdmitted: Bool,
    operationalValuesKnown: Bool,
    temporalMerkle: DisposalTemporalMerkleQualification
) -> DisposalLatticeInputs {
    let visible = facts.filter { $0.visibleOrdinal <= prefixOrdinal }
    let unknownLifecycleCoverage = visible.filter {
        $0.table == "frame_adapter_coverage" &&
            $0.attributes["adapter_state"] == "UNKNOWN_RAW_ONLY" &&
            $0.attributes["operational_scope"] == "LIFECYCLE"
    }
    let allCoverage = visible.filter { $0.table == "frame_adapter_coverage" }
    func coverageKnown(_ eventTypes: Set<String>) -> Bool {
        !unknownLifecycleCoverage.contains {
            guard let eventType = $0.attributes["event_type"] else { return true }
            return eventTypes.contains(eventType)
        }
    }
    func coverageHashes(_ eventTypes: Set<String>) -> [String] {
        allCoverage.filter {
            guard let eventType = $0.attributes["event_type"] else { return true }
            return eventTypes.contains(eventType)
        }.map(\.normalizedFactSHA256)
    }
    let snapshotCoverage = Set(["start", "snapshot"])
    let commitmentCoverage = Set(["commitment"])
    let signalCoverage = Set(["signal_call"])
    let conservationCoverage = Set(["conservation", "absence", "wait_reap"])
    let terminalCoverage = Set(["terminal"])
    let snapshots = visible.filter { fact in
        fact.table == "target_snapshots" &&
            ["PRESTATE", "PRECOMMIT_FIRST", "PRECOMMIT_SECOND"]
                .contains(fact.attributes["snapshot_phase"] ?? "")
    }
    let commitments = visible.filter { $0.table == "commitments" }
    let signals = visible.filter { $0.table == "signal_calls" }
    let conservations = visible.filter { $0.table == "conservations" }
    let terminals = visible.filter { $0.table == "terminal_outcomes" }
    let completeConservations = conservations.filter {
        $0.attributes["completion_state"] == "COMPLETE"
    }
    let enteredSignals = signals.filter {
        ["ENTERED", "MAY_HAVE_ENTERED"].contains($0.attributes["entry_state"] ?? "")
    }
    let enteredOutstanding = enteredSignals.contains { signal in
        guard let targetKey = signal.attributes["target_key"] else { return true }
        return !completeConservations.contains { conservation in
            conservation.visibleOrdinal > signal.visibleOrdinal &&
                conservation.attributes["target_key"] == targetKey
        }
    }
    let completeTargetKeys = Set(completeConservations.compactMap { $0.attributes["target_key"] })
    let ambiguousCompletedTarget = completeTargetKeys.contains { targetKey in
        commitments.filter { $0.attributes["target_key"] == targetKey }.count > 1
    }
    let exactTerminals = terminals.filter {
        ["EXACT_RETAINED", "EMPTY_RETAINED"].contains($0.attributes["capture_state"] ?? "")
    }
    let preactuationRejections = exactTerminals.filter {
        $0.attributes["completion_class"] == "PREACTUATION_REJECTED"
    }
    func hashes(_ rows: [DisposalMachineFact]) -> [String] {
        rows.map(\.normalizedFactSHA256)
    }
    let commitmentHashes = hashes(commitments)
    let signalHashes = hashes(signals)
    let conservationHashes = hashes(completeConservations)
    let terminalHashes = hashes(terminals)
    let setFacts = visible.filter {
        $0.table == "conservation_set_commitments" && $0.visibleOrdinal < prefixOrdinal
    }
    let membershipFacts = visible.filter {
        $0.table == "conservation_set_memberships" && $0.visibleOrdinal < prefixOrdinal
    }
    let proofFacts = visible.filter {
        $0.table == "conservation_set_membership_proof_nodes" &&
            $0.visibleOrdinal < prefixOrdinal
    }
    let mappingFacts = visible.filter { $0.table == "conservation_set_obligation_mappings" }
    let verifiedSetStateFacts = visible.filter {
        $0.table == "conservation_set_conservation_states" &&
            $0.attributes["merkle_state"] == "VERIFIED_PRIOR_EXACT"
    }
    let exactTemporalHashes = hashes(setFacts + membershipFacts + proofFacts)
    let conservationTemporalHashes = hashes(mappingFacts + verifiedSetStateFacts)
    let enteredWithoutComplete: Bool? = !ambiguousCompletedTarget
        ? enteredOutstanding : nil
    let exactSet: Bool? = temporalMerkle.exactCommitment
    let allConserved: Bool? = temporalMerkle.allCommittedObligationsConserved
    let snapshotCoverageHashes = coverageHashes(snapshotCoverage)
    let commitmentCoverageHashes = coverageHashes(commitmentCoverage)
    let signalCoverageHashes = coverageHashes(signalCoverage)
    let conservationCoverageHashes = coverageHashes(conservationCoverage)
    let terminalCoverageHashes = coverageHashes(terminalCoverage)
    let predicateKnowledge: [String: Bool] = [
        "preflight_snapshot_count": coverageKnown(snapshotCoverage),
        "commitment_count": coverageKnown(commitmentCoverage),
        "actuation_obligation_count": coverageKnown(commitmentCoverage),
        "commitment_vs_signal_result":
            coverageKnown(commitmentCoverage) && coverageKnown(signalCoverage),
        "entered_signal_without_complete_conservation":
            coverageKnown(signalCoverage) && coverageKnown(conservationCoverage) &&
                !ambiguousCompletedTarget,
        "exact_preconservation_obligation_set_commitment":
            coverageKnown(commitmentCoverage),
        "all_committed_obligations_conserved":
            coverageKnown(commitmentCoverage) && coverageKnown(conservationCoverage),
        "terminal_count": coverageKnown(terminalCoverage),
        "exact_terminal_count": coverageKnown(terminalCoverage),
        "preactuation_rejection_terminal_count":
            coverageKnown(terminalCoverage) && coverageKnown(signalCoverage),
        "entered_signal_count": coverageKnown(signalCoverage),
    ]
    let sources: [String: [String]] = [
        "input_set_admitted": [inputSetAdmitted ? "ADMITTED" : "EMPTY"],
        "preflight_snapshot_count": hashes(snapshots) + snapshotCoverageHashes,
        "commitment_count": commitmentHashes + commitmentCoverageHashes,
        "actuation_obligation_count": commitmentHashes + commitmentCoverageHashes,
        "commitment_vs_signal_result": commitmentHashes + signalHashes +
            commitmentCoverageHashes + signalCoverageHashes,
        "entered_signal_without_complete_conservation":
            hashes(enteredSignals) + conservationHashes + signalCoverageHashes +
                conservationCoverageHashes,
        "exact_preconservation_obligation_set_commitment":
            commitmentHashes + exactTemporalHashes + commitmentCoverageHashes,
        "all_committed_obligations_conserved":
            commitmentHashes + conservationHashes + exactTemporalHashes +
                conservationTemporalHashes +
                commitmentCoverageHashes + conservationCoverageHashes,
        "terminal_count": terminalHashes + terminalCoverageHashes,
        "exact_terminal_count": hashes(exactTerminals) + terminalCoverageHashes,
        "preactuation_rejection_terminal_count": hashes(preactuationRejections) +
            terminalCoverageHashes + signalCoverageHashes,
        "entered_signal_count": hashes(enteredSignals) + signalCoverageHashes,
    ]
    return DisposalLatticeInputs(
        inputSetAdmitted: inputSetAdmitted,
        operationalValuesKnown: operationalValuesKnown,
        predicateKnowledge: predicateKnowledge,
        preflightSnapshotCount: snapshots.count,
        commitmentCount: commitments.count,
        signalResultCount: signals.count,
        enteredSignalWithoutCompleteConservation: enteredWithoutComplete,
        exactPreconservationObligationSetCommitment: exactSet,
        allCommittedObligationsConserved: allConserved,
        terminalCount: terminals.count,
        exactTerminalCount: exactTerminals.count,
        preactuationRejectionTerminalCount: preactuationRejections.count,
        enteredSignalCount: enteredSignals.count,
        sources: sources)
}

private func disposalMachineOverlay(
    journal: DisposalDecodedJournal,
    evidence: DisposalEvidenceMaterial,
    invocationNode: String,
    frameNodes: [String]
) throws -> DisposalMachineOverlay {
    let rules = try disposalValidatedLattice(expectedSHA256: evidence.latticeSHA256)
    let facts = try disposalMachineFacts(journal: journal, evidence: evidence)
    try disposalRequireProjection(
        frameNodes.count == journal.frames.count,
        "GRAPH_MACHINE_FRAME_INVENTORY")
    guard !journal.frames.isEmpty else {
        throw DisposalProjectionRejection(code: "GRAPH_MACHINE_EMPTY_JOURNAL")
    }
    let sourceInvocationID = evidence.invocationID
    let sourceEpochLabel = evidence.epochLabel
    let semanticScopeSHA256 = disposalMachineID(
        "disposal-machine-semantic-scope-v1",
        [sourceInvocationID, sourceEpochLabel])
    let derivedPostHocMerkleConfigSHA256 = disposalMachineID(
        "disposal-derived-post-hoc-witness-merkle-config-v1",
        [
            "SHA256", "ERGENTICS_DISPOSAL_DERIVED_POST_HOC_WITNESS_PREFIX_V1",
            "CANONICAL_LEAF_KEY_BYTES_ASC", "REJECT_DUPLICATES",
            "RFC6962_LARGEST_POWER_OF_TWO_SPLIT",
        ])

    let witnesses = facts.map { fact -> DisposalMachineWitnessRow in
        let intrinsicSourceFrameLFSHA256: String? = fact.sourceFrameID.flatMap { frameID -> String? in
            guard let ordinal = evidence.frameIDs.firstIndex(of: frameID) else { return nil }
            return journal.frames[ordinal].rawWithLFSHA256
        }
        let witnessID = disposalMachineID(
            "disposal-machine-witness-v1",
            [fact.table, fact.normalizedFactSHA256,
             intrinsicSourceFrameLFSHA256 ?? "NO_INTRINSIC_SOURCE_FRAME",
             String(fact.visibleOrdinal), "00000000", "0", "0"])
        let sourceNode: String?
        if let frameID = fact.sourceFrameID,
           let ordinal = evidence.frameIDs.firstIndex(of: frameID)
        {
            sourceNode = frameNodes[ordinal]
        } else {
            sourceNode = nil
        }
        return .init(
            id: witnessID,
            table: fact.table,
            rowID: fact.rowID,
            exactRowSHA256: fact.exactRowSHA256,
            normalizedFactSHA256: fact.normalizedFactSHA256,
            intrinsicSourceFrameLFSHA256: intrinsicSourceFrameLFSHA256,
            sourceFrameNodeID: sourceNode,
            visibleOrdinal: fact.visibleOrdinal)
    }
    try disposalRequireProjection(
        Set(witnesses.map(\.id)).count == witnesses.count,
        "GRAPH_MACHINE_WITNESS_DUPLICATE")

    let baseInputs = disposalMachineInputs(
        prefixOrdinal: -1,
        facts: [],
        inputSetAdmitted: false,
        operationalValuesKnown: journal.sourceKind == .disposalEvent,
        temporalMerkle: .init(
            exactCommitment: false,
            allCommittedObligationsConserved: false,
            commitmentNormalizedFactSHA256: nil))
    let baseDecision = try disposalEvaluateLattice(rules: rules, inputs: baseInputs)
    try disposalRequireProjection(
        baseDecision.ruleID == "D00" && baseDecision.stateClass == "EMPTY",
        "GRAPH_MACHINE_GENESIS_LATTICE")
    let baseMerkle = try disposalDerivedPostHocMerkleRoot(normalizedFactSHA256s: [])
    let baseAncestry = disposalMachineID(
        "disposal-machine-prefix-ancestry-genesis-v1",
        [semanticScopeSHA256])
    let baseStateID = disposalMachineID(
        "disposal-machine-state-v1",
        [
            evidence.latticeSHA256, semanticScopeSHA256, "-1", "GENESIS",
            baseAncestry, "NO_FRAME",
            baseDecision.predicateVectorSHA256, baseDecision.ruleID, baseDecision.stateClass,
            baseMerkle.root, "0", derivedPostHocMerkleConfigSHA256,
            "00000000", "0", "0",
        ])
    var states: [DisposalMachineStateRow] = [.init(
        id: baseStateID,
        prefixOrdinal: -1,
        predecessorID: nil,
        ancestrySHA256: baseAncestry,
        highWaterFrameNodeID: nil,
        highWaterFrameLFSHA256: nil,
        ruleID: baseDecision.ruleID,
        predicateVectorSHA256: baseDecision.predicateVectorSHA256,
        stateClass: baseDecision.stateClass,
        derivedPostHocMerkleRootSHA256: baseMerkle.root,
        derivedPostHocMerkleLeafCount: 0)]
    var transitions: [DisposalMachineTransitionRow] = []
    var edges: [DisposalMachineOverlayEdgeRow] = []
    var merkleLeaves: [DisposalMachineMerkleLeafRow] = []
    var priorState = states[0]

    for prefixOrdinal in journal.frames.indices {
        let visibleWitnesses = witnesses.filter { $0.visibleOrdinal <= prefixOrdinal }
            .sorted { ($0.normalizedFactSHA256, $0.id) < ($1.normalizedFactSHA256, $1.id) }
        let merkle = try disposalDerivedPostHocMerkleRoot(
            normalizedFactSHA256s: visibleWitnesses.map(\.normalizedFactSHA256))
        let extractedTemporalMerkle = try disposalTemporalMerkleQualification(
            prefixOrdinal: prefixOrdinal,
            facts: facts,
            sourceInvocationID: sourceInvocationID,
            sourceEpochLabel: sourceEpochLabel)
        let temporalMerkle = journal.sourceKind == .disposalEvent
            ? extractedTemporalMerkle
            : DisposalTemporalMerkleQualification(
                exactCommitment: nil,
                allCommittedObligationsConserved: nil,
                commitmentNormalizedFactSHA256: nil)
        let decision = try disposalEvaluateLattice(
            rules: rules,
            inputs: disposalMachineInputs(
                prefixOrdinal: prefixOrdinal,
                facts: facts,
                inputSetAdmitted: true,
                operationalValuesKnown: journal.sourceKind == .disposalEvent,
                temporalMerkle: temporalMerkle))
        let frameHash = journal.frames[prefixOrdinal].rawWithLFSHA256
        let ancestry = disposalMachineID(
            "disposal-machine-prefix-ancestry-step-v1",
            [priorState.ancestrySHA256, frameHash])
        let stateID = disposalMachineID(
            "disposal-machine-state-v1",
            [
                evidence.latticeSHA256, semanticScopeSHA256, String(prefixOrdinal),
                priorState.id, ancestry,
                frameHash, decision.predicateVectorSHA256, decision.ruleID,
                decision.stateClass, merkle.root, String(visibleWitnesses.count),
                derivedPostHocMerkleConfigSHA256, "00000000", "0", "0",
            ])
        let state = DisposalMachineStateRow(
            id: stateID,
            prefixOrdinal: prefixOrdinal,
            predecessorID: priorState.id,
            ancestrySHA256: ancestry,
            highWaterFrameNodeID: frameNodes[prefixOrdinal],
            highWaterFrameLFSHA256: frameHash,
            ruleID: decision.ruleID,
            predicateVectorSHA256: decision.predicateVectorSHA256,
            stateClass: decision.stateClass,
            derivedPostHocMerkleRootSHA256: merkle.root,
            derivedPostHocMerkleLeafCount: visibleWitnesses.count)
        let sourceSet = disposalStableSetSHA256(
            domain: "disposal-machine-derived-post-hoc-source-set-v1",
            values: visibleWitnesses.map(\.normalizedFactSHA256))
        let preconservationState = temporalMerkle.exactCommitment.map {
            $0 ? "TRUE" : "FALSE"
        } ?? "UNKNOWN"
        let preconservationWitnessID = temporalMerkle.commitmentNormalizedFactSHA256.flatMap {
            normalized in witnesses.first(where: {
                $0.normalizedFactSHA256 == normalized
            })?.id
        }
        try disposalRequireProjection(
            (preconservationState == "TRUE") == (preconservationWitnessID != nil),
            "GRAPH_TEMPORAL_MERKLE_WITNESS_JOIN")
        let transitionID = disposalMachineID(
            "disposal-machine-transition-v1",
            [
                evidence.latticeSHA256, semanticScopeSHA256, priorState.id, state.id,
                ancestry, frameHash,
                decision.predicateVectorSHA256, decision.ruleID, decision.stateClass,
                sourceSet, priorState.derivedPostHocMerkleRootSHA256,
                String(priorState.derivedPostHocMerkleLeafCount),
                derivedPostHocMerkleConfigSHA256, preconservationState,
                preconservationWitnessID ?? "NO_PRECONSERVATION_COMMITMENT_WITNESS",
                "00000000", "0", "0",
            ])
        let transition = DisposalMachineTransitionRow(
            id: transitionID,
            fromStateID: priorState.id,
            toStateID: state.id,
            acceptedFrameNodeID: frameNodes[prefixOrdinal],
            acceptedFrameLFSHA256: frameHash,
            ruleID: decision.ruleID,
            stateClass: decision.stateClass,
            predicateVectorSHA256: decision.predicateVectorSHA256,
            derivedPostHocSourceSetSHA256: sourceSet,
            predecessorDerivedPostHocMerkleRootSHA256:
                priorState.derivedPostHocMerkleRootSHA256,
            predecessorDerivedPostHocMerkleLeafCount:
                priorState.derivedPostHocMerkleLeafCount,
            preconservationMerkleCommitted: preconservationState,
            preconservationCommitmentWitnessID: preconservationWitnessID,
            predicates: decision.predicates)
        states.append(state)
        transitions.append(transition)
        edges.append(.init(
            id: disposalMachineID(
                "disposal-machine-overlay-edge-v1",
                [priorState.id, transition.id, "PREDECESSOR"]),
            from: priorState.id, to: transition.id, role: "PREDECESSOR"))
        edges.append(.init(
            id: disposalMachineID(
                "disposal-machine-overlay-edge-v1",
                [transition.id, state.id, "SUCCESSOR"]),
            from: transition.id, to: state.id, role: "SUCCESSOR"))
        for witness in visibleWitnesses {
            edges.append(.init(
                id: disposalMachineID(
                    "disposal-machine-overlay-edge-v1",
                    [witness.id, transition.id, "SUPPORTS"]),
                from: witness.id, to: transition.id, role: "SUPPORTS"))
        }
        for (ordinal, witness) in visibleWitnesses.enumerated() {
            merkleLeaves.append(.init(
                stateID: state.id,
                ordinal: ordinal,
                witnessID: witness.id,
                normalizedLeafSHA256: disposalMachineID(
                    "disposal-derived-post-hoc-witness-merkle-leaf-v1",
                    [witness.normalizedFactSHA256])))
        }
        priorState = state
    }

    return .init(
        states: states,
        transitions: transitions,
        witnesses: witnesses,
        edges: edges,
        merkleLeaves: merkleLeaves)
}

private func disposalTypedEvidenceGraphRows(
    evidence: DisposalEvidenceMaterial,
    invocationNode: String,
    frameNodesByID: [String: String]
) throws -> DisposalTypedEvidenceGraphRows {
    let database = try DisposalSQLiteConnection(serializedReadOnly: evidence.database)
    var nodes: [DisposalGraphNodeRow] = []
    var edges: [DisposalGraphEdgeRow] = []
    var entityNodes: [String: String] = [:]

    func rows(_ sql: String, columns: Int) throws -> [[String?]] {
        let statement = try database.prepare(sql)
        var result: [[String?]] = []
        while try statement.step() {
            result.append((0..<columns).map { statement.optionalText(Int32($0)) })
        }
        return result
    }

    func required(
        _ row: [String?],
        _ column: Int,
        _ code: String
    ) throws -> String {
        guard let value = row[column] else {
            throw DisposalProjectionRejection(code: code)
        }
        return value
    }

    func identifiers(_ sql: String) throws -> [String] {
        try rows(sql, columns: 1).map {
            try required($0, 0, "GRAPH_TYPED_INVENTORY_ID")
        }
    }

    func entityKey(_ table: String, _ rowID: String) -> String {
        table + ":" + rowID
    }

    func appendNode(
        table: String,
        rowID: String,
        kind: String,
        key: String,
        label: String
    ) throws -> String {
        let entity = entityKey(table, rowID)
        try disposalRequireProjection(
            entityNodes[entity] == nil,
            "GRAPH_TYPED_NODE_DUPLICATE",
            detail: entity)
        let nodeID = disposalID(
            "disposal-graph-node-v1",
            [kind, key, "EVIDENCE", rowID])
        nodes.append(.init(
            id: nodeID,
            kind: kind,
            key: key,
            label: label,
            databaseRole: "EVIDENCE",
            sourceRowID: rowID))
        entityNodes[entity] = nodeID
        return nodeID
    }

    func node(_ table: String, _ rowID: String, _ code: String) throws -> String {
        guard let value = entityNodes[entityKey(table, rowID)] else {
            throw DisposalProjectionRejection(code: code, detail: table + ":" + rowID)
        }
        return value
    }

    func appendEdge(
        from: String,
        predicate: String,
        to: String,
        rowID: String,
        pointer: String? = nil
    ) {
        let grade = "FOREIGN_KEY_EXACT"
        let edgeID = disposalID(
            "disposal-graph-edge-v1",
            [from, predicate, to, "EVIDENCE", rowID, pointer ?? "NULL", grade])
        edges.append(.init(
            id: edgeID,
            from: from,
            predicate: predicate,
            to: to,
            databaseRole: "EVIDENCE",
            sourceRowID: rowID,
            pointer: pointer,
            grade: grade))
    }

    func frameReports(
        _ frameID: String,
        _ entityNode: String,
        _ rowID: String,
        _ pointer: String
    ) throws {
        guard let frameNode = frameNodesByID[frameID] else {
            throw DisposalProjectionRejection(
                code: "GRAPH_TYPED_FRAME_JOIN",
                detail: frameID)
        }
        appendEdge(
            from: frameNode,
            predicate: "FRAME_REPORTS_ENTITY",
            to: entityNode,
            rowID: rowID,
            pointer: pointer)
    }

    func targetReference(
        from entityNode: String,
        targetID: String,
        rowID: String,
        pointer: String
    ) throws {
        appendEdge(
            from: entityNode,
            predicate: "ENTITY_REFERENCES_TARGET",
            to: try node("targets", targetID, "GRAPH_TYPED_TARGET_JOIN"),
            rowID: rowID,
            pointer: pointer)
    }

    let typedInventories: [(String, [String], [String])] = [
        ("frame_adapter_coverage", try identifiers(
            "SELECT frame_id FROM frame_adapter_coverage ORDER BY frame_id"),
         evidence.typedEvidenceIDs.frameAdapterCoverageIDs.sorted()),
        ("targets", try identifiers("SELECT target_id FROM targets ORDER BY target_id"),
         evidence.typedEvidenceIDs.targetIDs.sorted()),
        ("process_receipts", try identifiers(
            "SELECT receipt_id FROM process_receipts ORDER BY receipt_id"),
         evidence.typedEvidenceIDs.processReceiptIDs.sorted()),
        ("vnode_joins", try identifiers("SELECT join_id FROM vnode_joins ORDER BY join_id"),
         evidence.typedEvidenceIDs.vnodeJoinIDs.sorted()),
        ("domain_snapshots", try identifiers(
            "SELECT domain_snapshot_id FROM domain_snapshots ORDER BY domain_snapshot_id"),
         evidence.typedEvidenceIDs.domainSnapshotIDs.sorted()),
        ("target_snapshots", try identifiers(
            "SELECT snapshot_id FROM target_snapshots ORDER BY snapshot_id"),
         evidence.typedEvidenceIDs.targetSnapshotIDs.sorted()),
        ("snapshot_pairs", try identifiers("SELECT pair_id FROM snapshot_pairs ORDER BY pair_id"),
         evidence.typedEvidenceIDs.snapshotPairIDs.sorted()),
        ("namespace_observations", try identifiers(
            "SELECT namespace_observation_id FROM namespace_observations " +
                "ORDER BY namespace_observation_id"),
         evidence.typedEvidenceIDs.namespaceObservationIDs.sorted()),
        ("commitments", try identifiers(
            "SELECT commitment_id FROM commitments ORDER BY commitment_id"),
         evidence.typedEvidenceIDs.commitmentIDs.sorted()),
        ("signal_calls", try identifiers(
            "SELECT signal_call_id FROM signal_calls ORDER BY signal_call_id"),
         evidence.typedEvidenceIDs.signalCallIDs.sorted()),
        ("signal_zero_calls", try identifiers(
            "SELECT signal_zero_call_id FROM signal_zero_calls ORDER BY signal_zero_call_id"),
         evidence.typedEvidenceIDs.signalZeroCallIDs.sorted()),
        ("wait_calls", try identifiers("SELECT wait_call_id FROM wait_calls ORDER BY wait_call_id"),
         evidence.typedEvidenceIDs.waitCallIDs.sorted()),
        ("reap_results", try identifiers("SELECT reap_id FROM reap_results ORDER BY reap_id"),
         evidence.typedEvidenceIDs.reapIDs.sorted()),
        ("absence_proofs", try identifiers(
            "SELECT absence_proof_id FROM absence_proofs ORDER BY absence_proof_id"),
         evidence.typedEvidenceIDs.absenceProofIDs.sorted()),
        ("conservations", try identifiers(
            "SELECT conservation_id FROM conservations ORDER BY conservation_id"),
         evidence.typedEvidenceIDs.conservationIDs.sorted()),
        ("conservation_set_commitments", try identifiers(
            "SELECT conservation_set_commitment_id FROM conservation_set_commitments " +
                "ORDER BY conservation_set_commitment_id"),
         evidence.typedEvidenceIDs.conservationSetCommitmentIDs.sorted()),
        ("conservation_set_memberships", try identifiers(
            "SELECT membership_id FROM conservation_set_memberships ORDER BY membership_id"),
         evidence.typedEvidenceIDs.conservationSetMembershipIDs.sorted()),
        ("conservation_set_obligation_mappings", try identifiers(
            "SELECT mapping_id FROM conservation_set_obligation_mappings ORDER BY mapping_id"),
         evidence.typedEvidenceIDs.conservationSetMappingIDs.sorted()),
    ]
    for (table, observed, expected) in typedInventories {
        try disposalRequireProjection(
            observed == expected,
            "GRAPH_TYPED_INVENTORY_JOIN",
            detail: table)
    }

    for row in try rows(
        "SELECT frame_id,payload_schema,adapter_state,operational_scope " +
            "FROM frame_adapter_coverage ORDER BY frame_id",
        columns: 4)
    {
        let frameID = try required(row, 0, "GRAPH_COVERAGE_FRAME")
        let entityNode = try appendNode(
            table: "frame_adapter_coverage",
            rowID: frameID,
            kind: "ADAPTER_COVERAGE",
            key: "adapter-coverage:" + frameID,
            label: (try required(row, 2, "GRAPH_COVERAGE_STATE")) + " " +
                (try required(row, 3, "GRAPH_COVERAGE_SCOPE")))
        try frameReports(
            frameID, entityNode, frameID, "/frame_adapter_coverage/frame_id")
    }

    for row in try rows(
        "SELECT target_id,invocation_id,target_role,numeric_pid FROM targets ORDER BY target_id",
        columns: 4)
    {
        let targetID = try required(row, 0, "GRAPH_TARGET_ID")
        let invocationID = try required(row, 1, "GRAPH_TARGET_INVOCATION")
        try disposalRequireProjection(
            invocationID == evidence.invocationID,
            "GRAPH_TARGET_INVOCATION_JOIN")
        let role = try required(row, 2, "GRAPH_TARGET_ROLE")
        let pid = try required(row, 3, "GRAPH_TARGET_PID")
        let targetNode = try appendNode(
            table: "targets",
            rowID: targetID,
            kind: "TARGET",
            key: "target:" + targetID,
            label: role + " pid=" + pid)
        appendEdge(
            from: invocationNode,
            predicate: "INVOCATION_HAS_TARGET",
            to: targetNode,
            rowID: targetID,
            pointer: "/targets/invocation_id")
    }

    for row in try rows(
        "SELECT receipt_id,source_frame_id,target_id,observation_kind,pid " +
            "FROM process_receipts ORDER BY receipt_id",
        columns: 5)
    {
        let rowID = try required(row, 0, "GRAPH_RECEIPT_ID")
        let entityNode = try appendNode(
            table: "process_receipts",
            rowID: rowID,
            kind: "RECEIPT",
            key: "receipt:" + rowID,
            label: (try required(row, 3, "GRAPH_RECEIPT_KIND")) +
                " pid=" + (try required(row, 4, "GRAPH_RECEIPT_PID")))
        try frameReports(
            try required(row, 1, "GRAPH_RECEIPT_FRAME"),
            entityNode,
            rowID,
            "/process_receipts/source_frame_id")
        if let targetID = row[2] {
            try targetReference(
                from: entityNode,
                targetID: targetID,
                rowID: rowID,
                pointer: "/process_receipts/target_id")
        }
    }

    for row in try rows(
        "SELECT join_id,source_frame_id,receipt_id,join_kind FROM vnode_joins ORDER BY join_id",
        columns: 4)
    {
        let rowID = try required(row, 0, "GRAPH_VNODE_ID")
        let entityNode = try appendNode(
            table: "vnode_joins",
            rowID: rowID,
            kind: "VNODE_JOIN",
            key: "vnode-join:" + rowID,
            label: try required(row, 3, "GRAPH_VNODE_KIND"))
        try frameReports(
            try required(row, 1, "GRAPH_VNODE_FRAME"),
            entityNode,
            rowID,
            "/vnode_joins/source_frame_id")
        appendEdge(
            from: entityNode,
            predicate: "VNODE_JOIN_USES_RECEIPT",
            to: try node(
                "process_receipts",
                try required(row, 2, "GRAPH_VNODE_RECEIPT"),
                "GRAPH_VNODE_RECEIPT_JOIN"),
            rowID: rowID,
            pointer: "/vnode_joins/receipt_id")
    }

    for row in try rows(
        "SELECT domain_snapshot_id,source_frame_id,target_id,domain_kind,numeric_domain " +
            "FROM domain_snapshots ORDER BY domain_snapshot_id",
        columns: 5)
    {
        let rowID = try required(row, 0, "GRAPH_DOMAIN_ID")
        let entityNode = try appendNode(
            table: "domain_snapshots",
            rowID: rowID,
            kind: "DOMAIN_SNAPSHOT",
            key: "domain-snapshot:" + rowID,
            label: (try required(row, 3, "GRAPH_DOMAIN_KIND")) +
                " " + (try required(row, 4, "GRAPH_DOMAIN_NUMBER")))
        try frameReports(
            try required(row, 1, "GRAPH_DOMAIN_FRAME"),
            entityNode,
            rowID,
            "/domain_snapshots/source_frame_id")
        try targetReference(
            from: entityNode,
            targetID: try required(row, 2, "GRAPH_DOMAIN_TARGET"),
            rowID: rowID,
            pointer: "/domain_snapshots/target_id")
    }

    for row in try rows(
        "SELECT domain_snapshot_id,member_ordinal,receipt_id " +
            "FROM domain_members ORDER BY domain_snapshot_id,member_ordinal",
        columns: 3)
    {
        let domainID = try required(row, 0, "GRAPH_DOMAIN_MEMBER_DOMAIN")
        let ordinal = try required(row, 1, "GRAPH_DOMAIN_MEMBER_ORDINAL")
        let receiptID = try required(row, 2, "GRAPH_DOMAIN_MEMBER_RECEIPT")
        let rowID = domainID + "#" + ordinal
        appendEdge(
            from: try node("domain_snapshots", domainID, "GRAPH_DOMAIN_MEMBER_DOMAIN_JOIN"),
            predicate: "DOMAIN_CONTAINS_RECEIPT",
            to: try node("process_receipts", receiptID, "GRAPH_DOMAIN_MEMBER_RECEIPT_JOIN"),
            rowID: rowID,
            pointer: "/domain_members/receipt_id")
    }

    for row in try rows(
        "SELECT snapshot_id,source_frame_id,target_id,snapshot_phase,snapshot_kind," +
            "receipt_id,image_join_id,cwd_join_id,group_snapshot_id,session_snapshot_id " +
            "FROM target_snapshots ORDER BY snapshot_id",
        columns: 10)
    {
        let rowID = try required(row, 0, "GRAPH_SNAPSHOT_ID")
        let entityNode = try appendNode(
            table: "target_snapshots",
            rowID: rowID,
            kind: "SNAPSHOT",
            key: "snapshot:" + rowID,
            label: (try required(row, 3, "GRAPH_SNAPSHOT_PHASE")) +
                " " + (try required(row, 4, "GRAPH_SNAPSHOT_KIND")))
        try frameReports(
            try required(row, 1, "GRAPH_SNAPSHOT_FRAME"),
            entityNode,
            rowID,
            "/target_snapshots/source_frame_id")
        let targetID = try required(row, 2, "GRAPH_SNAPSHOT_TARGET")
        appendEdge(
            from: entityNode,
            predicate: "SNAPSHOT_DESCRIBES_TARGET",
            to: try node("targets", targetID, "GRAPH_SNAPSHOT_TARGET_JOIN"),
            rowID: rowID,
            pointer: "/target_snapshots/target_id")
        if let receiptID = row[5] {
            appendEdge(
                from: entityNode,
                predicate: "SNAPSHOT_USES_RECEIPT",
                to: try node("process_receipts", receiptID, "GRAPH_SNAPSHOT_RECEIPT_JOIN"),
                rowID: rowID,
                pointer: "/target_snapshots/receipt_id")
        }
        for (column, pointer) in [(6, "image_join_id"), (7, "cwd_join_id")] {
            if let joinID = row[column] {
                appendEdge(
                    from: entityNode,
                    predicate: "SNAPSHOT_USES_VNODE_JOIN",
                    to: try node("vnode_joins", joinID, "GRAPH_SNAPSHOT_VNODE_JOIN"),
                    rowID: rowID,
                    pointer: "/target_snapshots/" + pointer)
            }
        }
        for (column, pointer) in [(8, "group_snapshot_id"), (9, "session_snapshot_id")] {
            if let domainID = row[column] {
                appendEdge(
                    from: entityNode,
                    predicate: "SNAPSHOT_USES_DOMAIN_SNAPSHOT",
                    to: try node("domain_snapshots", domainID, "GRAPH_SNAPSHOT_DOMAIN_JOIN"),
                    rowID: rowID,
                    pointer: "/target_snapshots/" + pointer)
            }
        }
    }

    for row in try rows(
        "SELECT pair_id,source_frame_id,target_id,pair_phase,first_snapshot_id,second_snapshot_id " +
            "FROM snapshot_pairs ORDER BY pair_id",
        columns: 6)
    {
        let rowID = try required(row, 0, "GRAPH_PAIR_ID")
        let entityNode = try appendNode(
            table: "snapshot_pairs",
            rowID: rowID,
            kind: "SNAPSHOT_PAIR",
            key: "snapshot-pair:" + rowID,
            label: try required(row, 3, "GRAPH_PAIR_PHASE"))
        try frameReports(
            try required(row, 1, "GRAPH_PAIR_FRAME"),
            entityNode,
            rowID,
            "/snapshot_pairs/source_frame_id")
        try targetReference(
            from: entityNode,
            targetID: try required(row, 2, "GRAPH_PAIR_TARGET"),
            rowID: rowID,
            pointer: "/snapshot_pairs/target_id")
        if let firstID = row[4] {
            appendEdge(
                from: entityNode,
                predicate: "PAIR_REFERENCES_FIRST",
                to: try node("target_snapshots", firstID, "GRAPH_PAIR_FIRST_JOIN"),
                rowID: rowID,
                pointer: "/snapshot_pairs/first_snapshot_id")
        }
        if let secondID = row[5] {
            appendEdge(
                from: entityNode,
                predicate: "PAIR_REFERENCES_SECOND",
                to: try node("target_snapshots", secondID, "GRAPH_PAIR_SECOND_JOIN"),
                rowID: rowID,
                pointer: "/snapshot_pairs/second_snapshot_id")
        }
    }

    for row in try rows(
        "SELECT commitment_id,source_frame_id,target_id,operation,prestate_pair_id " +
            "FROM commitments ORDER BY commitment_id",
        columns: 5)
    {
        let rowID = try required(row, 0, "GRAPH_COMMITMENT_ID")
        let entityNode = try appendNode(
            table: "commitments",
            rowID: rowID,
            kind: "COMMITMENT",
            key: "commitment:" + rowID,
            label: try required(row, 3, "GRAPH_COMMITMENT_OPERATION"))
        try frameReports(
            try required(row, 1, "GRAPH_COMMITMENT_FRAME"),
            entityNode,
            rowID,
            "/commitments/source_frame_id")
        try targetReference(
            from: entityNode,
            targetID: try required(row, 2, "GRAPH_COMMITMENT_TARGET"),
            rowID: rowID,
            pointer: "/commitments/target_id")
        if let pairID = row[4] {
            appendEdge(
                from: entityNode,
                predicate: "COMMITMENT_REFERENCES_PAIR",
                to: try node("snapshot_pairs", pairID, "GRAPH_COMMITMENT_PAIR_JOIN"),
                rowID: rowID,
                pointer: "/commitments/prestate_pair_id")
        }
    }

    for row in try rows(
        "SELECT signal_call_id,commitment_id,source_frame_id,postcommit_pair_id,signal_number " +
            "FROM signal_calls ORDER BY signal_call_id",
        columns: 5)
    {
        let rowID = try required(row, 0, "GRAPH_SIGNAL_CALL_ID")
        let entityNode = try appendNode(
            table: "signal_calls",
            rowID: rowID,
            kind: "SIGNAL_CALL",
            key: "signal-call:" + rowID,
            label: "signal " + (try required(row, 4, "GRAPH_SIGNAL_NUMBER")))
        if let frameID = row[2] {
            try frameReports(frameID, entityNode, rowID, "/signal_calls/source_frame_id")
        }
        appendEdge(
            from: entityNode,
            predicate: "CALL_REFERENCES_COMMITMENT",
            to: try node(
                "commitments",
                try required(row, 1, "GRAPH_SIGNAL_COMMITMENT"),
                "GRAPH_SIGNAL_COMMITMENT_JOIN"),
            rowID: rowID,
            pointer: "/signal_calls/commitment_id")
        if let pairID = row[3] {
            appendEdge(
                from: entityNode,
                predicate: "CALL_REFERENCES_PAIR",
                to: try node("snapshot_pairs", pairID, "GRAPH_SIGNAL_PAIR_JOIN"),
                rowID: rowID,
                pointer: "/signal_calls/postcommit_pair_id")
        }
    }

    for row in try rows(
        "SELECT signal_zero_call_id,source_frame_id,target_id,result_class " +
            "FROM signal_zero_calls ORDER BY signal_zero_call_id",
        columns: 4)
    {
        let rowID = try required(row, 0, "GRAPH_SIGNAL_ZERO_ID")
        let entityNode = try appendNode(
            table: "signal_zero_calls",
            rowID: rowID,
            kind: "SIGNAL_ZERO_CALL",
            key: "signal-zero-call:" + rowID,
            label: try required(row, 3, "GRAPH_SIGNAL_ZERO_RESULT"))
        try frameReports(
            try required(row, 1, "GRAPH_SIGNAL_ZERO_FRAME"),
            entityNode,
            rowID,
            "/signal_zero_calls/source_frame_id")
        try targetReference(
            from: entityNode,
            targetID: try required(row, 2, "GRAPH_SIGNAL_ZERO_TARGET"),
            rowID: rowID,
            pointer: "/signal_zero_calls/target_id")
    }

    for row in try rows(
        "SELECT wait_call_id,source_frame_id,target_id,wait_ownership,wait_api " +
            "FROM wait_calls ORDER BY wait_call_id",
        columns: 5)
    {
        let rowID = try required(row, 0, "GRAPH_WAIT_ID")
        let entityNode = try appendNode(
            table: "wait_calls",
            rowID: rowID,
            kind: "WAIT",
            key: "wait:" + rowID,
            label: (try required(row, 3, "GRAPH_WAIT_OWNERSHIP")) +
                " " + (try required(row, 4, "GRAPH_WAIT_API")))
        try frameReports(
            try required(row, 1, "GRAPH_WAIT_FRAME"),
            entityNode,
            rowID,
            "/wait_calls/source_frame_id")
        try targetReference(
            from: entityNode,
            targetID: try required(row, 2, "GRAPH_WAIT_TARGET"),
            rowID: rowID,
            pointer: "/wait_calls/target_id")
    }

    for row in try rows(
        "SELECT reap_id,wait_call_id,source_frame_id,target_id,returned_pid " +
            "FROM reap_results ORDER BY reap_id",
        columns: 5)
    {
        let rowID = try required(row, 0, "GRAPH_REAP_ID")
        let entityNode = try appendNode(
            table: "reap_results",
            rowID: rowID,
            kind: "REAP",
            key: "reap:" + rowID,
            label: "pid=" + (try required(row, 4, "GRAPH_REAP_PID")))
        try frameReports(
            try required(row, 2, "GRAPH_REAP_FRAME"),
            entityNode,
            rowID,
            "/reap_results/source_frame_id")
        try targetReference(
            from: entityNode,
            targetID: try required(row, 3, "GRAPH_REAP_TARGET"),
            rowID: rowID,
            pointer: "/reap_results/target_id")
        appendEdge(
            from: try node(
                "wait_calls",
                try required(row, 1, "GRAPH_REAP_WAIT"),
                "GRAPH_REAP_WAIT_JOIN"),
            predicate: "WAIT_RETURNED_REAP_RECEIPT",
            to: entityNode,
            rowID: rowID,
            pointer: "/reap_results/wait_call_id")
    }

    for row in try rows(
        "SELECT absence_proof_id,source_frame_id,target_id,proof_kind " +
            "FROM absence_proofs ORDER BY absence_proof_id",
        columns: 4)
    {
        let rowID = try required(row, 0, "GRAPH_ABSENCE_ID")
        let entityNode = try appendNode(
            table: "absence_proofs",
            rowID: rowID,
            kind: "ABSENCE_PROOF",
            key: "absence-proof:" + rowID,
            label: try required(row, 3, "GRAPH_ABSENCE_KIND"))
        try frameReports(
            try required(row, 1, "GRAPH_ABSENCE_FRAME"),
            entityNode,
            rowID,
            "/absence_proofs/source_frame_id")
        try targetReference(
            from: entityNode,
            targetID: try required(row, 2, "GRAPH_ABSENCE_TARGET"),
            rowID: rowID,
            pointer: "/absence_proofs/target_id")
    }

    for row in try rows(
        "SELECT absence_proof_id,attempt_ordinal,generation_state,group_snapshot_id," +
            "session_snapshot_id,signal_zero_call_id FROM absence_attempts " +
            "ORDER BY absence_proof_id,attempt_ordinal",
        columns: 6)
    {
        let proofID = try required(row, 0, "GRAPH_ATTEMPT_PROOF")
        let ordinal = try required(row, 1, "GRAPH_ATTEMPT_ORDINAL")
        let rowID = proofID + "#" + ordinal
        let entityNode = try appendNode(
            table: "absence_attempts",
            rowID: rowID,
            kind: "ABSENCE_ATTEMPT",
            key: "absence-attempt:" + rowID,
            label: "round " + ordinal + " " +
                (try required(row, 2, "GRAPH_ATTEMPT_STATE")))
        appendEdge(
            from: try node("absence_proofs", proofID, "GRAPH_ATTEMPT_PROOF_JOIN"),
            predicate: "ABSENCE_PROOF_USES_ATTEMPT",
            to: entityNode,
            rowID: rowID,
            pointer: "/absence_attempts/absence_proof_id")
        for (column, pointer) in [(3, "group_snapshot_id"), (4, "session_snapshot_id")] {
            if let domainID = row[column] {
                appendEdge(
                    from: entityNode,
                    predicate: "ATTEMPT_USES_DOMAIN_SNAPSHOT",
                    to: try node("domain_snapshots", domainID, "GRAPH_ATTEMPT_DOMAIN_JOIN"),
                    rowID: rowID,
                    pointer: "/absence_attempts/" + pointer)
            }
        }
        if let callID = row[5] {
            appendEdge(
                from: entityNode,
                predicate: "ATTEMPT_USES_SIGNAL_ZERO",
                to: try node("signal_zero_calls", callID, "GRAPH_ATTEMPT_SIGNAL_ZERO_JOIN"),
                rowID: rowID,
                pointer: "/absence_attempts/signal_zero_call_id")
        }
    }

    for row in try rows(
        "SELECT absence_proof_id,accepted_ordinal,attempt_ordinal " +
            "FROM accepted_absence_rounds ORDER BY absence_proof_id,accepted_ordinal",
        columns: 3)
    {
        let proofID = try required(row, 0, "GRAPH_ACCEPTED_PROOF")
        let acceptedOrdinal = try required(row, 1, "GRAPH_ACCEPTED_ORDINAL")
        let attemptOrdinal = try required(row, 2, "GRAPH_ACCEPTED_ATTEMPT")
        let rowID = proofID + "#accepted-" + acceptedOrdinal
        appendEdge(
            from: try node("absence_proofs", proofID, "GRAPH_ACCEPTED_PROOF_JOIN"),
            predicate: "ABSENCE_PROOF_ACCEPTS_ATTEMPT",
            to: try node(
                "absence_attempts",
                proofID + "#" + attemptOrdinal,
                "GRAPH_ACCEPTED_ATTEMPT_JOIN"),
            rowID: rowID,
            pointer: "/accepted_absence_rounds/attempt_ordinal")
    }

    for row in try rows(
        "SELECT conservation_id,source_frame_id,target_id,absence_proof_id,reap_id," +
            "completion_state FROM conservations ORDER BY conservation_id",
        columns: 6)
    {
        let rowID = try required(row, 0, "GRAPH_CONSERVATION_ID")
        let entityNode = try appendNode(
            table: "conservations",
            rowID: rowID,
            kind: "CONSERVATION",
            key: "conservation:" + rowID,
            label: try required(row, 5, "GRAPH_CONSERVATION_STATE"))
        try frameReports(
            try required(row, 1, "GRAPH_CONSERVATION_FRAME"),
            entityNode,
            rowID,
            "/conservations/source_frame_id")
        try targetReference(
            from: entityNode,
            targetID: try required(row, 2, "GRAPH_CONSERVATION_TARGET"),
            rowID: rowID,
            pointer: "/conservations/target_id")
        appendEdge(
            from: entityNode,
            predicate: "CONSERVATION_USES_ABSENCE_PROOF",
            to: try node(
                "absence_proofs",
                try required(row, 3, "GRAPH_CONSERVATION_PROOF"),
                "GRAPH_CONSERVATION_PROOF_JOIN"),
            rowID: rowID,
            pointer: "/conservations/absence_proof_id")
        if let reapID = row[4] {
            appendEdge(
                from: entityNode,
                predicate: "CONSERVATION_REFERENCES_REAP",
                to: try node("reap_results", reapID, "GRAPH_CONSERVATION_REAP_JOIN"),
                rowID: rowID,
                pointer: "/conservations/reap_id")
        }
    }

    for row in try rows(
        "SELECT namespace_observation_id,source_frame_id,namespace_kind,observation_state " +
            "FROM namespace_observations ORDER BY namespace_observation_id",
        columns: 4)
    {
        let rowID = try required(row, 0, "GRAPH_NAMESPACE_ID")
        let entityNode = try appendNode(
            table: "namespace_observations",
            rowID: rowID,
            kind: "NAMESPACE_OBSERVATION",
            key: "namespace-observation:" + rowID,
            label: (try required(row, 2, "GRAPH_NAMESPACE_KIND")) + " " +
                (try required(row, 3, "GRAPH_NAMESPACE_STATE")))
        try frameReports(
            try required(row, 1, "GRAPH_NAMESPACE_FRAME"),
            entityNode,
            rowID,
            "/namespace_observations/source_frame_id")
    }

    for row in try rows(
        "SELECT missing_id,source_frame_id,evidence_kind,reason_code " +
            "FROM missing_evidence ORDER BY missing_id",
        columns: 4)
    {
        let rowID = try required(row, 0, "GRAPH_MISSING_ID")
        let entityNode = try appendNode(
            table: "missing_evidence",
            rowID: rowID,
            kind: "MISSING_EVIDENCE",
            key: "missing-evidence:" + rowID,
            label: (try required(row, 2, "GRAPH_MISSING_KIND")) + " " +
                (try required(row, 3, "GRAPH_MISSING_REASON")))
        if let frameID = row[1] {
            try frameReports(frameID, entityNode, rowID, "/missing_evidence/source_frame_id")
        } else {
            appendEdge(
                from: invocationNode,
                predicate: "INVOCATION_REPORTS_MISSING_EVIDENCE",
                to: entityNode,
                rowID: rowID,
                pointer: "/missing_evidence/invocation_id")
        }
    }

    for row in try rows(
        "SELECT terminal_outcome_id,terminal_frame_id,status_text,gate_c_conservation_id," +
            "guardian_conservation_id,wrapper_conservation_id,fixture_conservation_id " +
            "FROM terminal_outcomes ORDER BY terminal_outcome_id",
        columns: 7)
    {
        let rowID = try required(row, 0, "GRAPH_TERMINAL_ID")
        let entityNode = try appendNode(
            table: "terminal_outcomes",
            rowID: rowID,
            kind: "TERMINAL_OUTCOME",
            key: "terminal-outcome:" + rowID,
            label: try required(row, 2, "GRAPH_TERMINAL_STATUS"))
        try frameReports(
            try required(row, 1, "GRAPH_TERMINAL_FRAME"),
            entityNode,
            rowID,
            "/terminal_outcomes/terminal_frame_id")
        for (column, pointer) in [
            (3, "gate_c_conservation_id"), (4, "guardian_conservation_id"),
            (5, "wrapper_conservation_id"), (6, "fixture_conservation_id"),
        ] {
            if let conservationID = row[column] {
                appendEdge(
                    from: entityNode,
                    predicate: "TERMINAL_REFERENCES_CONSERVATION",
                    to: try node(
                        "conservations",
                        conservationID,
                        "GRAPH_TERMINAL_CONSERVATION_JOIN"),
                    rowID: rowID,
                    pointer: "/terminal_outcomes/" + pointer)
            }
        }
    }

    for row in try rows(
        "SELECT conservation_set_commitment_id,source_frame_id,witness_root_sha256,leaf_count " +
            "FROM conservation_set_commitments ORDER BY conservation_set_commitment_id",
        columns: 4)
    {
        let rowID = try required(row, 0, "GRAPH_SET_ID")
        let entityNode = try appendNode(
            table: "conservation_set_commitments", rowID: rowID,
            kind: "CONSERVATION_SET_COMMITMENT", key: "conservation-set:" + rowID,
            label: "Conservation set leaves=" + (try required(row, 3, "GRAPH_SET_COUNT")))
        try frameReports(
            try required(row, 1, "GRAPH_SET_FRAME"), entityNode, rowID,
            "/conservation_set_commitments/source_frame_id")
    }

    for row in try rows(
        "SELECT membership_id,conservation_set_commitment_id,obligation_commitment_id," +
            "obligation_key_sha256 FROM conservation_set_memberships ORDER BY membership_id",
        columns: 4)
    {
        let rowID = try required(row, 0, "GRAPH_SET_MEMBERSHIP_ID")
        let entityNode = try appendNode(
            table: "conservation_set_memberships", rowID: rowID,
            kind: "CONSERVATION_SET_MEMBERSHIP", key: "conservation-membership:" + rowID,
            label: "Obligation " + (try required(row, 3, "GRAPH_SET_MEMBERSHIP_KEY")))
        appendEdge(
            from: try node(
                "conservation_set_commitments",
                try required(row, 1, "GRAPH_SET_MEMBERSHIP_SET"),
                "GRAPH_SET_MEMBERSHIP_SET_JOIN"),
            predicate: "SET_CONTAINS_MEMBERSHIP", to: entityNode, rowID: rowID,
            pointer: "/conservation_set_memberships/conservation_set_commitment_id")
        appendEdge(
            from: entityNode, predicate: "MEMBERSHIP_REFERENCES_COMMITMENT",
            to: try node(
                "commitments", try required(row, 2, "GRAPH_SET_MEMBERSHIP_COMMITMENT"),
                "GRAPH_SET_MEMBERSHIP_COMMITMENT_JOIN"),
            rowID: rowID,
            pointer: "/conservation_set_memberships/obligation_commitment_id")
    }

    for row in try rows(
        "SELECT membership_id,proof_ordinal,sibling_position,sibling_sha256 " +
            "FROM conservation_set_membership_proof_nodes " +
            "ORDER BY membership_id,proof_ordinal",
        columns: 4)
    {
        let membershipID = try required(row, 0, "GRAPH_SET_PROOF_MEMBERSHIP")
        let ordinal = try required(row, 1, "GRAPH_SET_PROOF_ORDINAL")
        let rowID = membershipID + "#" + ordinal
        let entityNode = try appendNode(
            table: "conservation_set_membership_proof_nodes", rowID: rowID,
            kind: "MERKLE_PROOF_NODE", key: "conservation-proof-node:" + rowID,
            label: (try required(row, 2, "GRAPH_SET_PROOF_POSITION")) + " " +
                (try required(row, 3, "GRAPH_SET_PROOF_HASH")))
        appendEdge(
            from: try node(
                "conservation_set_memberships", membershipID,
                "GRAPH_SET_PROOF_MEMBERSHIP_JOIN"),
            predicate: "MEMBERSHIP_HAS_PROOF_NODE", to: entityNode, rowID: rowID,
            pointer: "/conservation_set_membership_proof_nodes/membership_id")
    }

    for row in try rows(
        "SELECT conservation_id,conservation_set_commitment_id,merkle_state " +
            "FROM conservation_set_conservation_states ORDER BY conservation_id",
        columns: 3)
    {
        let conservationID = try required(row, 0, "GRAPH_SET_STATE_CONSERVATION")
        let rowID = conservationID
        let entityNode = try appendNode(
            table: "conservation_set_conservation_states", rowID: rowID,
            kind: "CONSERVATION_SET_STATE", key: "conservation-set-state:" + rowID,
            label: try required(row, 2, "GRAPH_SET_STATE"))
        appendEdge(
            from: try node("conservations", conservationID, "GRAPH_SET_STATE_CONSERVATION_JOIN"),
            predicate: "CONSERVATION_HAS_SET_STATE", to: entityNode, rowID: rowID,
            pointer: "/conservation_set_conservation_states/conservation_id")
        if let setID = row[1] {
            appendEdge(
                from: entityNode, predicate: "SET_STATE_REFERENCES_SET",
                to: try node(
                    "conservation_set_commitments", setID, "GRAPH_SET_STATE_SET_JOIN"),
                rowID: rowID,
                pointer: "/conservation_set_conservation_states/conservation_set_commitment_id")
        }
    }

    for row in try rows(
        "SELECT mapping_id,conservation_id,conservation_set_commitment_id,membership_id " +
            "FROM conservation_set_obligation_mappings ORDER BY mapping_id",
        columns: 4)
    {
        let rowID = try required(row, 0, "GRAPH_SET_MAPPING_ID")
        let entityNode = try appendNode(
            table: "conservation_set_obligation_mappings", rowID: rowID,
            kind: "CONSERVATION_SET_MAPPING", key: "conservation-set-mapping:" + rowID,
            label: "Explicit obligation conservation mapping")
        for (column, table, predicate, pointer, code) in [
            (1, "conservations", "SET_MAPPING_REFERENCES_CONSERVATION", "conservation_id",
             "GRAPH_SET_MAPPING_CONSERVATION_JOIN"),
            (2, "conservation_set_commitments", "SET_MAPPING_REFERENCES_SET",
             "conservation_set_commitment_id", "GRAPH_SET_MAPPING_SET_JOIN"),
            (3, "conservation_set_memberships", "SET_MAPPING_REFERENCES_MEMBERSHIP",
             "membership_id", "GRAPH_SET_MAPPING_MEMBERSHIP_JOIN"),
        ] {
            appendEdge(
                from: entityNode, predicate: predicate,
                to: try node(table, try required(row, column, code), code), rowID: rowID,
                pointer: "/conservation_set_obligation_mappings/" + pointer)
        }
    }

    for row in try rows(
        "SELECT window_id,target_id,start_frame_id,end_frame_id,commitment_id,signal_call_id " +
            "FROM risk_windows ORDER BY window_id",
        columns: 6)
    {
        let rowID = try required(row, 0, "GRAPH_WINDOW_ID")
        let entityNode = disposalID(
            "disposal-graph-node-v1",
            ["RISK_WINDOW", "risk:" + rowID, "EVIDENCE", rowID])
        if let targetID = row[1] {
            try targetReference(
                from: entityNode,
                targetID: targetID,
                rowID: rowID,
                pointer: "/risk_windows/target_id")
        }
        for (column, pointer) in [(2, "start_frame_id"), (3, "end_frame_id")] {
            if let frameID = row[column] {
                guard let frameNode = frameNodesByID[frameID] else {
                    throw DisposalProjectionRejection(code: "GRAPH_WINDOW_FRAME_JOIN")
                }
                appendEdge(
                    from: entityNode,
                    predicate: "WINDOW_SPANS_EVENTS",
                    to: frameNode,
                    rowID: rowID,
                    pointer: "/risk_windows/" + pointer)
            }
        }
        if let commitmentID = row[4] {
            appendEdge(
                from: entityNode,
                predicate: "WINDOW_REFERENCES_COMMITMENT",
                to: try node(
                    "commitments",
                    commitmentID,
                    "GRAPH_WINDOW_COMMITMENT_JOIN"),
                rowID: rowID,
                pointer: "/risk_windows/commitment_id")
        }
        if let callID = row[5] {
            appendEdge(
                from: entityNode,
                predicate: "WINDOW_REFERENCES_SIGNAL_CALL",
                to: try node("signal_calls", callID, "GRAPH_WINDOW_SIGNAL_JOIN"),
                rowID: rowID,
                pointer: "/risk_windows/signal_call_id")
        }
    }

    try database.close()
    return .init(nodes: nodes, edges: edges)
}

func buildDisposalGraph(
    journal: DisposalDecodedJournal,
    evidence: DisposalEvidenceMaterial,
    metrics: DisposalMetricsMaterial
) throws -> DisposalGraphMaterial {
    let ddl = try disposalResourceData("001-graph", extension: "sql")
    let ddlSHA256 = disposalSHA256(ddl)
    var nodes: [DisposalGraphNodeRow] = []
    var edges: [DisposalGraphEdgeRow] = []

    func appendNode(
        kind: String,
        key: String,
        label: String,
        role: String,
        row: String
    ) -> String {
        let id = disposalID("disposal-graph-node-v1", [kind, key, role, row])
        nodes.append(.init(
            id: id,
            kind: kind,
            key: key,
            label: label,
            databaseRole: role,
            sourceRowID: row))
        return id
    }

    func appendEdge(
        from: String,
        predicate: String,
        to: String,
        role: String,
        row: String,
        pointer: String? = nil,
        grade: String = "FOREIGN_KEY_EXACT"
    ) {
        let id = disposalID(
            "disposal-graph-edge-v1",
            [from, predicate, to, role, row, pointer ?? "NULL", grade])
        edges.append(.init(
            id: id,
            from: from,
            predicate: predicate,
            to: to,
            databaseRole: role,
            sourceRowID: row,
            pointer: pointer,
            grade: grade))
    }

    let invocationNode = appendNode(
        kind: "INVOCATION",
        key: "invocation:\(evidence.invocationID)",
        label: journal.sourceKind == .disposalEvent
            ? "Disposal invocation"
            : "R19 observability presentation",
        role: "EVIDENCE",
        row: evidence.invocationID)
    let streamNode = appendNode(
        kind: "STREAM",
        key: "stream:\(evidence.streamID)",
        label: journal.isTerminal
            ? "Complete disposal journal"
            : (journal.sourceSealed
                ? "Sealed observability source; disposal outcome absent"
                : "Unsealed source prefix"),
        role: "EVIDENCE",
        row: evidence.streamID)
    var frameNodes: [String] = []
    for frame in journal.frames {
        let node = appendNode(
            kind: "FRAME",
            key: "frame:\(evidence.frameIDs[frame.ordinal])",
            label: "\(frame.ordinal):\(frame.sourceFrameKind.rawValue)",
            role: "EVIDENCE",
            row: evidence.frameIDs[frame.ordinal])
        frameNodes.append(node)
        appendEdge(
            from: streamNode,
            predicate: "STREAM_CONTAINS_FRAME",
            to: node,
            role: "EVIDENCE",
            row: evidence.frameIDs[frame.ordinal])
        if frame.ordinal > 0 {
            appendEdge(
                from: frameNodes[frame.ordinal - 1],
                predicate: "FRAME_PRECEDES_FRAME",
                to: node,
                role: "EVIDENCE",
                row: evidence.frameIDs[frame.ordinal])
        }
    }

    let riskFrames = journal.frames.filter { $0.eventType == .riskWindow }
    for (index, riskID) in evidence.riskWindowIDs.enumerated() {
        let node = appendNode(
            kind: "RISK_WINDOW",
            key: "risk:\(riskID)",
            label: try riskFrames[index].requiredString(at: "/payload/window_kind"),
            role: "EVIDENCE",
            row: riskID)
        appendEdge(
            from: frameNodes[riskFrames[index].ordinal],
            predicate: "FRAME_REPORTS_ENTITY",
            to: node,
            role: "EVIDENCE",
            row: riskID,
            pointer: "/payload/window_kind",
            grade: "SOURCE_POINTER_EXACT")
    }

    let frameNodesByID = Dictionary(
        uniqueKeysWithValues: zip(evidence.frameIDs, frameNodes))
    let typedEvidenceRows = try disposalTypedEvidenceGraphRows(
        evidence: evidence,
        invocationNode: invocationNode,
        frameNodesByID: frameNodesByID)
    nodes.append(contentsOf: typedEvidenceRows.nodes)
    edges.append(contentsOf: typedEvidenceRows.edges)

    var sampleNodes: [String: String] = [:]
    for sampleID in metrics.sampleIDs.sorted() {
        sampleNodes[sampleID] = appendNode(
            kind: "RUSAGE_SAMPLE",
            key: "rusage:\(sampleID)",
            label: "Rusage sample",
            role: "METRICS",
            row: sampleID)
    }
    var metricNodes: [String: String] = [:]
    for metricID in metrics.metricIDs.sorted() {
        metricNodes[metricID] = appendNode(
            kind: "METRIC",
            key: "metric:\(metricID)",
            label: "Exact rational metric",
            role: "METRICS",
            row: metricID)
    }

    let metricsDatabase = try DisposalSQLiteConnection(serializedReadOnly: metrics.database)
    var joinedSampleIDs: [String] = []
    do {
        let sampleJoin = try metricsDatabase.prepare(
            "SELECT sample_id,source_frame_id,source_target_id " +
                "FROM rusage_samples ORDER BY sample_id")
        while try sampleJoin.step() {
            guard let sampleID = sampleJoin.optionalText(0),
                  let sourceFrameID = sampleJoin.optionalText(1),
                  let targetID = sampleJoin.optionalText(2),
                  let sampleNode = sampleNodes[sampleID],
                  let frameOrdinal = evidence.frameIDs.firstIndex(of: sourceFrameID)
            else {
                throw DisposalProjectionRejection(code: "GRAPH_SAMPLE_FRAME_JOIN")
            }
            joinedSampleIDs.append(sampleID)
            appendEdge(
                from: frameNodes[frameOrdinal],
                predicate: "FRAME_REPORTS_ENTITY",
                to: sampleNode,
                role: "METRICS",
                row: sampleID,
                pointer: journal.frames[frameOrdinal].sourceFrameKind == .r19ObservabilitySample
                    ? "/payload/rusage_v6"
                    : "/payload/resource_sample",
                grade: "LEXICAL_EQUALITY_ONLY")
            if journal.frames[frameOrdinal].sourceFrameKind == .r19ObservabilitySample {
                guard evidence.typedEvidenceIDs.targetIDs.contains(targetID),
                      let targetNode = typedEvidenceRows.nodes.first(where: {
                          $0.kind == "TARGET" && $0.sourceRowID == targetID
                      })?.id
                else {
                    throw DisposalProjectionRejection(code: "GRAPH_R19_SAMPLE_TARGET_JOIN")
                }
                appendEdge(
                    from: sampleNode,
                    predicate: "ENTITY_REFERENCES_TARGET",
                    to: targetNode,
                    role: "METRICS",
                    row: sampleID,
                    pointer: "/rusage_samples/source_target_id",
                    grade: "SOURCE_POINTER_EXACT")
            }
        }
    }
    try disposalRequireProjection(
        joinedSampleIDs == metrics.sampleIDs.sorted(),
        "GRAPH_SAMPLE_INVENTORY_JOIN")

    var joinedMetricIDs: [String] = []
    do {
        let metricJoin = try metricsDatabase.prepare(
            "SELECT m.metric_id,i.before_sample_id,i.after_sample_id " +
                "FROM metric_facts m JOIN metric_intervals i ON i.interval_id=m.interval_id " +
                "ORDER BY m.metric_id")
        while try metricJoin.step() {
            guard let metricID = metricJoin.optionalText(0),
                  let beforeSampleID = metricJoin.optionalText(1),
                  let afterSampleID = metricJoin.optionalText(2),
                  let metricNode = metricNodes[metricID],
                  let beforeNode = sampleNodes[beforeSampleID],
                  let afterNode = sampleNodes[afterSampleID]
            else {
                throw DisposalProjectionRejection(code: "GRAPH_METRIC_SAMPLE_JOIN")
            }
            joinedMetricIDs.append(metricID)
            for sampleNode in [beforeNode, afterNode] {
                appendEdge(
                    from: metricNode,
                    predicate: "METRIC_USES_SAMPLE",
                    to: sampleNode,
                    role: "METRICS",
                    row: metricID,
                    grade: "FOREIGN_KEY_EXACT")
            }
        }
    }
    try disposalRequireProjection(
        joinedMetricIDs == metrics.metricIDs.sorted(),
        "GRAPH_METRIC_INVENTORY_JOIN")
    try metricsDatabase.close()

    let digestValues = [
        ("evidence", evidence.databaseSHA256, "EVIDENCE"),
        ("metrics", metrics.databaseSHA256, "METRICS"),
    ]
    for (label, digest, role) in digestValues {
        let digestNode = appendNode(
            kind: "DIGEST",
            key: "sha256:\(digest)",
            label: "\(label) SHA-256",
            role: role,
            row: digest)
        appendEdge(
            from: invocationNode,
            predicate: "ENTITY_HASHES_TO",
            to: digestNode,
            role: role,
            row: digest,
            grade: "COMPUTED_SHA256_EXACT")
    }

    let machine = try disposalMachineOverlay(
        journal: journal,
        evidence: evidence,
        invocationNode: invocationNode,
        frameNodes: frameNodes)
    guard let finalState = machine.states.last else {
        throw DisposalProjectionRejection(code: "GRAPH_MACHINE_FINAL_STATE")
    }
    nodes.sort { $0.id < $1.id }
    edges.sort { $0.id < $1.id }
    let stateClass = finalState.stateClass
    let stateRuleID = finalState.ruleID
    let graphExportSHA256 = disposalGraphExport(
        nodes: nodes,
        edges: edges,
        machine: machine,
        stateClass: stateClass,
        stateRuleID: stateRuleID)
    let projectionID = disposalID(
        "ergentics-disposal-graph-projection-v1",
        [
            evidence.projectionID,
            evidence.databaseSHA256,
            metrics.projectionID,
            metrics.databaseSHA256,
            ddlSHA256,
            evidence.adapterSHA256,
            evidence.latticeSHA256,
            graphExportSHA256,
        ])

    let database = try DisposalSQLiteConnection()
    guard let ddlText = String(data: ddl, encoding: .utf8) else {
        throw DisposalProjectionRejection(code: "GRAPH_DDL_UTF8")
    }
    try database.execute(ddlText)
    let applicationID = try database.scalarInt("PRAGMA application_id")
    let userVersion = try database.scalarInt("PRAGMA user_version")
    try disposalRequireProjection(
        applicationID == 1_162_102_577,
        "GRAPH_APPLICATION_ID")
    try disposalRequireProjection(
        userVersion == 1,
        "GRAPH_USER_VERSION")
    try database.execute("BEGIN IMMEDIATE")
    do {
        let policy = try database.prepare(
            "INSERT INTO projection_policy VALUES(1,?,?,?,?,?,?)")
        try policy.bind(1, text: "ergentics_disposal_graph_v1")
        try policy.bind(2, text: "00000000")
        try policy.bind(3, int: 0)
        try policy.bind(4, int: 0)
        try policy.bind(5, int: 0)
        try policy.bind(6, text: "EMPTY_OR_EXPLICIT_ABSTAIN_NO_STALE_FALLBACK")
        try policy.stepDone()

        let input = try database.prepare("INSERT INTO input_databases VALUES(?,?,?,?,?)")
        for value in [
            ("EVIDENCE", evidence.projectionID, evidence.databaseSHA256,
             evidence.database.count, evidence.relationalExportSHA256),
            ("METRICS", metrics.projectionID, metrics.databaseSHA256,
             metrics.database.count, metrics.relationalExportSHA256),
        ] {
            input.reset()
            try input.bind(1, text: value.0)
            try input.bind(2, text: value.1)
            try input.bind(3, text: value.2)
            try input.bind(4, int: value.3)
            try input.bind(5, text: value.4)
            try input.stepDone()
        }

        let nodeStatement = try database.prepare(
            "INSERT INTO graph_nodes VALUES(?,?,?,?,?,?,0)")
        for node in nodes {
            nodeStatement.reset()
            try nodeStatement.bind(1, text: node.id)
            try nodeStatement.bind(2, text: node.kind)
            try nodeStatement.bind(3, text: node.key)
            try nodeStatement.bind(4, text: node.label)
            try nodeStatement.bind(5, text: node.databaseRole)
            try nodeStatement.bind(6, text: node.sourceRowID)
            try nodeStatement.stepDone()
        }

        let edgeStatement = try database.prepare(
            "INSERT INTO graph_edges VALUES(?,?,?,?,?,?,?,?,0,0)")
        for edge in edges {
            edgeStatement.reset()
            try edgeStatement.bind(1, text: edge.id)
            try edgeStatement.bind(2, text: edge.from)
            try edgeStatement.bind(3, text: edge.predicate)
            try edgeStatement.bind(4, text: edge.to)
            try edgeStatement.bind(5, text: edge.databaseRole)
            try edgeStatement.bind(6, text: edge.sourceRowID)
            try edgeStatement.bind(7, text: edge.pointer)
            try edgeStatement.bind(8, text: edge.grade)
            try edgeStatement.stepDone()
        }

        let machineNode = try database.prepare(
            "INSERT INTO machine_nodes VALUES(?,?,?,0,0)")
        for state in machine.states {
            machineNode.reset()
            try machineNode.bind(1, text: state.id)
            try machineNode.bind(2, text: "OBJECT")
            try machineNode.bind(3, text: "STATE")
            try machineNode.stepDone()
        }
        for witness in machine.witnesses {
            machineNode.reset()
            try machineNode.bind(1, text: witness.id)
            try machineNode.bind(2, text: "OBJECT")
            try machineNode.bind(3, text: "WITNESS")
            try machineNode.stepDone()
        }
        for transition in machine.transitions {
            machineNode.reset()
            try machineNode.bind(1, text: transition.id)
            try machineNode.bind(2, text: "RELATION")
            try machineNode.bind(3, text: "TRANSITION")
            try machineNode.stepDone()
        }

        let machineState = try database.prepare(
            "INSERT INTO machine_states VALUES(" + String(repeating: "?,", count: 15) +
                "?,0,0)")
        let machineStateBinding = try database.prepare(
            "INSERT INTO machine_state_bindings VALUES(?,?,?)")
        for state in machine.states {
            machineState.reset()
            try machineState.bind(1, text: state.id)
            try machineState.bind(2, int: state.prefixOrdinal)
            try machineState.bind(3, text: state.predecessorID)
            try machineState.bind(4, text: state.ancestrySHA256)
            try machineState.bind(5, text: state.highWaterFrameLFSHA256)
            try machineState.bind(6, text: state.ruleID)
            try machineState.bind(7, text: state.predicateVectorSHA256)
            try machineState.bind(8, text: state.stateClass)
            try machineState.bind(9, text: state.derivedPostHocMerkleRootSHA256)
            try machineState.bind(10, int: state.derivedPostHocMerkleLeafCount)
            try machineState.bind(11, text: "SHA256")
            try machineState.bind(
                12, text: "ERGENTICS_DISPOSAL_DERIVED_POST_HOC_WITNESS_PREFIX_V1")
            try machineState.bind(13, text: "CANONICAL_LEAF_KEY_BYTES_ASC")
            try machineState.bind(14, text: "REJECT_DUPLICATES")
            try machineState.bind(15, text: "RFC6962_LARGEST_POWER_OF_TWO_SPLIT")
            try machineState.bind(16, text: "00000000")
            try machineState.stepDone()
            machineStateBinding.reset()
            try machineStateBinding.bind(1, text: state.id)
            try machineStateBinding.bind(2, text: invocationNode)
            try machineStateBinding.bind(3, text: state.highWaterFrameNodeID)
            try machineStateBinding.stepDone()
        }

        let machineWitness = try database.prepare(
            "INSERT INTO machine_witnesses VALUES(?,?,?,?,?,0,0)")
        let machineWitnessBinding = try database.prepare(
            "INSERT INTO machine_witness_bindings VALUES(?,?,?,?,?,?)")
        for witness in machine.witnesses {
            machineWitness.reset()
            try machineWitness.bind(1, text: witness.id)
            try machineWitness.bind(2, text: witness.table)
            try machineWitness.bind(3, text: witness.normalizedFactSHA256)
            try machineWitness.bind(4, text: witness.intrinsicSourceFrameLFSHA256)
            try machineWitness.bind(5, int: witness.visibleOrdinal)
            try machineWitness.stepDone()
            machineWitnessBinding.reset()
            try machineWitnessBinding.bind(1, text: witness.id)
            try machineWitnessBinding.bind(2, text: "EVIDENCE")
            try machineWitnessBinding.bind(3, text: witness.table)
            try machineWitnessBinding.bind(4, text: witness.rowID)
            try machineWitnessBinding.bind(5, text: witness.exactRowSHA256)
            try machineWitnessBinding.bind(6, text: witness.sourceFrameNodeID)
            try machineWitnessBinding.stepDone()
        }

        let machineTransition = try database.prepare(
            "INSERT INTO machine_transitions VALUES(" + String(repeating: "?,", count: 12) +
                "?,0,0)")
        let machineTransitionBinding = try database.prepare(
            "INSERT INTO machine_transition_bindings VALUES(?,?)")
        for transition in machine.transitions {
            machineTransition.reset()
            try machineTransition.bind(1, text: transition.id)
            try machineTransition.bind(2, text: transition.fromStateID)
            try machineTransition.bind(3, text: transition.toStateID)
            try machineTransition.bind(4, text: transition.acceptedFrameLFSHA256)
            try machineTransition.bind(5, text: transition.ruleID)
            try machineTransition.bind(6, text: transition.stateClass)
            try machineTransition.bind(7, text: transition.predicateVectorSHA256)
            try machineTransition.bind(8, text: transition.derivedPostHocSourceSetSHA256)
            try machineTransition.bind(
                9, text: transition.predecessorDerivedPostHocMerkleRootSHA256)
            try machineTransition.bind(
                10, int: transition.predecessorDerivedPostHocMerkleLeafCount)
            try machineTransition.bind(11, text: transition.preconservationMerkleCommitted)
            try machineTransition.bind(12, text: transition.preconservationCommitmentWitnessID)
            try machineTransition.bind(13, text: "00000000")
            try machineTransition.stepDone()
            machineTransitionBinding.reset()
            try machineTransitionBinding.bind(1, text: transition.id)
            try machineTransitionBinding.bind(2, text: transition.acceptedFrameNodeID)
            try machineTransitionBinding.stepDone()
        }

        let machinePredicate = try database.prepare(
            "INSERT INTO machine_transition_predicates VALUES(" +
                String(repeating: "?,", count: 13) + "?)")
        for transition in machine.transitions {
            for predicate in transition.predicates {
                machinePredicate.reset()
                try machinePredicate.bind(1, text: transition.id)
                try machinePredicate.bind(2, int: predicate.ordinal)
                try machinePredicate.bind(3, int: predicate.ruleOrdinal)
                try machinePredicate.bind(4, text: predicate.ruleID)
                try machinePredicate.bind(5, int: predicate.clauseOrdinal)
                try machinePredicate.bind(6, text: predicate.clause)
                try machinePredicate.bind(7, text: predicate.lhs)
                try machinePredicate.bind(8, text: predicate.comparisonOperator)
                try machinePredicate.bind(9, text: predicate.rhs)
                try machinePredicate.bind(10, text: predicate.actualScalar)
                try machinePredicate.bind(11, text: predicate.normalizedState)
                try machinePredicate.bind(12, int: predicate.sourceCount)
                try machinePredicate.bind(13, text: predicate.sourceSetSHA256)
                try machinePredicate.bind(14, text: predicate.predicateSHA256)
                try machinePredicate.stepDone()
            }
        }

        let machineMerkleLeaf = try database.prepare(
            "INSERT INTO machine_merkle_leaves VALUES(?,?,?,?)")
        for leaf in machine.merkleLeaves {
            machineMerkleLeaf.reset()
            try machineMerkleLeaf.bind(1, text: leaf.stateID)
            try machineMerkleLeaf.bind(2, int: leaf.ordinal)
            try machineMerkleLeaf.bind(3, text: leaf.witnessID)
            try machineMerkleLeaf.bind(4, text: leaf.normalizedLeafSHA256)
            try machineMerkleLeaf.stepDone()
        }

        let machineEdge = try database.prepare(
            "INSERT INTO machine_overlay_edges VALUES(?,?,?, ?,0,0)")
        for edge in machine.edges {
            machineEdge.reset()
            try machineEdge.bind(1, text: edge.id)
            try machineEdge.bind(2, text: edge.from)
            try machineEdge.bind(3, text: edge.to)
            try machineEdge.bind(4, text: edge.role)
            try machineEdge.stepDone()
        }

        let transitionCount = Int64(machine.transitions.count)
        let insertedTransitionCount = try database.scalarInt(
            "SELECT count(*) FROM machine_transitions")
        let transitionBindingCount = try database.scalarInt(
            "SELECT count(*) FROM machine_transition_bindings")
        let predecessorEdgeCount = try database.scalarInt(
            "SELECT count(*) FROM machine_overlay_edges WHERE edge_role='PREDECESSOR'")
        let successorEdgeCount = try database.scalarInt(
            "SELECT count(*) FROM machine_overlay_edges WHERE edge_role='SUCCESSOR'")
        try disposalRequireProjection(
            insertedTransitionCount == transitionCount &&
                transitionBindingCount == transitionCount &&
                predecessorEdgeCount == transitionCount &&
                successorEdgeCount == transitionCount,
            "GRAPH_MACHINE_TRANSITION_CARDINALITY")
        try disposalRequireProjection(
            try database.scalarInt(
                "SELECT count(*) FROM machine_transitions t WHERE " +
                    "(SELECT count(*) FROM machine_overlay_edges e WHERE " +
                    "e.edge_role='PREDECESSOR' AND e.from_node_id=t.from_state_id " +
                    "AND e.to_node_id=t.transition_id)<>1 OR " +
                    "(SELECT count(*) FROM machine_overlay_edges e WHERE " +
                    "e.edge_role='SUCCESSOR' AND e.from_node_id=t.transition_id " +
                    "AND e.to_node_id=t.to_state_id)<>1") == 0,
            "GRAPH_MACHINE_EDGE_EXACTNESS")
        try disposalRequireProjection(
            try database.scalarInt(
                "SELECT count(*) FROM machine_states s WHERE s.prefix_ordinal>=0 AND " +
                    "(SELECT count(*) FROM machine_transitions t WHERE t.to_state_id=s.state_id)<>1") == 0,
            "GRAPH_MACHINE_STATE_INCOMING")
        try disposalRequireProjection(
            try database.scalarInt(
                "SELECT count(*) FROM machine_transitions t WHERE " +
                    "(SELECT count(*) FROM machine_overlay_edges e WHERE " +
                    "e.edge_role='SUPPORTS' AND e.to_node_id=t.transition_id)<>" +
                    "(SELECT count(*) FROM machine_witnesses w WHERE w.visible_prefix_ordinal<=" +
                    "(SELECT prefix_ordinal FROM machine_states WHERE state_id=t.to_state_id))") == 0,
            "GRAPH_MACHINE_SUPPORT_SET")
        try disposalRequireProjection(
            try database.scalarInt(
                "SELECT count(*) FROM machine_states s WHERE " +
                    "(SELECT count(*) FROM machine_merkle_leaves l WHERE l.state_id=s.state_id)" +
                    "<>s.derived_post_hoc_witness_leaf_count OR " +
                    "(s.derived_post_hoc_witness_leaf_count>0 AND (" +
                    "(SELECT min(leaf_ordinal) FROM machine_merkle_leaves l " +
                    "WHERE l.state_id=s.state_id)<>0 OR " +
                    "(SELECT max(leaf_ordinal) FROM machine_merkle_leaves l " +
                    "WHERE l.state_id=s.state_id)<>s.derived_post_hoc_witness_leaf_count-1))") == 0,
            "GRAPH_MACHINE_MERKLE_CARDINALITY")
        let machineMerkleAudit = try database.prepare(
            "SELECT w.normalized_fact_sha256,l.normalized_leaf_sha256 " +
                "FROM machine_merkle_leaves l JOIN machine_witnesses w " +
                "ON w.witness_id=l.witness_id WHERE l.state_id=? ORDER BY l.leaf_ordinal")
        for state in machine.states {
            machineMerkleAudit.reset()
            try machineMerkleAudit.bind(1, text: state.id)
            var normalizedFacts: [String] = []
            while try machineMerkleAudit.step() {
                guard let normalizedFact = machineMerkleAudit.optionalText(0),
                      let storedLeaf = machineMerkleAudit.optionalText(1)
                else {
                    throw DisposalProjectionRejection(code: "GRAPH_MACHINE_MERKLE_ROW")
                }
                try disposalRequireProjection(
                    storedLeaf == disposalMachineID(
                        "disposal-derived-post-hoc-witness-merkle-leaf-v1",
                        [normalizedFact]),
                    "GRAPH_MACHINE_MERKLE_LEAF_HASH")
                normalizedFacts.append(normalizedFact)
            }
            let recomputed = try disposalDerivedPostHocMerkleRoot(
                normalizedFactSHA256s: normalizedFacts)
            try disposalRequireProjection(
                recomputed.root == state.derivedPostHocMerkleRootSHA256 &&
                    recomputed.orderedLeaves.count == state.derivedPostHocMerkleLeafCount,
                "GRAPH_MACHINE_MERKLE_ROOT")
        }
        try disposalRequireProjection(
            try database.scalarInt(
                "SELECT count(*) FROM machine_transitions t WHERE NOT EXISTS(" +
                    "SELECT 1 FROM machine_transition_predicates p " +
                    "WHERE p.transition_id=t.transition_id AND p.rule_id=t.matched_rule_id " +
                    "GROUP BY p.rule_id HAVING min(p.normalized_state='TRUE')=1)") == 0,
            "GRAPH_MACHINE_MATCHED_RULE_ALL_TRUE")
        try disposalRequireProjection(
            try database.scalarInt(
                "SELECT count(*) FROM machine_transitions t WHERE EXISTS(" +
                    "SELECT 1 FROM machine_transition_predicates earlier " +
                    "WHERE earlier.transition_id=t.transition_id AND earlier.rule_ordinal<" +
                    "(SELECT min(rule_ordinal) FROM machine_transition_predicates matched " +
                    "WHERE matched.transition_id=t.transition_id AND matched.rule_id=t.matched_rule_id) " +
                    "GROUP BY earlier.rule_ordinal HAVING min(earlier.normalized_state='TRUE')=1)") == 0,
            "GRAPH_MACHINE_FIRST_MATCH")

        let evaluationID = disposalID(
            "disposal-state-evaluation-v1",
            [evidence.invocationID, evidence.latticeSHA256, stateRuleID, stateClass,
             finalState.predicateVectorSHA256])
        let evaluation = try database.prepare(
            "INSERT INTO state_evaluations VALUES(?,?,?,?,?,?,?,0,0)")
        try evaluation.bind(1, text: evaluationID)
        try evaluation.bind(2, text: invocationNode)
        try evaluation.bind(3, text: stateRuleID)
        try evaluation.bind(4, text: evidence.latticeSHA256)
        try evaluation.bind(5, text: frameNodes.last)
        try evaluation.bind(6, text: stateClass)
        try evaluation.bind(7, text: "00000000")
        try evaluation.stepDone()

        let stateInput = try database.prepare(
            "INSERT INTO state_inputs VALUES(?,?,?,?)")
        for (ordinal, frameNode) in frameNodes.enumerated() {
            stateInput.reset()
            try stateInput.bind(1, text: evaluationID)
            try stateInput.bind(2, int: ordinal)
            try stateInput.bind(3, text: frameNode)
            try stateInput.bind(4, text: journal.frames[ordinal].rawWithLFSHA256)
            try stateInput.stepDone()
        }

        let seal = try database.prepare(
            "INSERT INTO graph_seal VALUES(" + String(repeating: "?,", count: 13) + "?)")
        try seal.bind(1, int: 1)
        try seal.bind(2, text: projectionID)
        try seal.bind(3, text: evidence.databaseSHA256)
        try seal.bind(4, text: metrics.databaseSHA256)
        try seal.bind(5, text: ddlSHA256)
        try seal.bind(6, text: evidence.adapterSHA256)
        try seal.bind(7, text: evidence.latticeSHA256)
        try seal.bind(8, text: graphExportSHA256)
        try seal.bind(9, int: nodes.count)
        try seal.bind(10, int: edges.count)
        try seal.bind(11, int: 1)
        try seal.bind(12, text: "00000000")
        try seal.bind(13, int: 0)
        try seal.bind(14, int: 0)
        try seal.stepDone()

        try database.execute("COMMIT")
        let integrityCheck = try database.scalarText("PRAGMA integrity_check")
        let foreignKeyFailures = try database.scalarInt(
            "SELECT count(*) FROM pragma_foreign_key_check")
        try disposalRequireProjection(
            integrityCheck == "ok",
            "GRAPH_INTEGRITY_CHECK")
        try disposalRequireProjection(
            foreignKeyFailures == 0,
            "GRAPH_FOREIGN_KEY_CHECK")
        let serialized = try database.serialized()
        try database.close()
        return .init(
            database: serialized,
            databaseSHA256: disposalSHA256(serialized),
            projectionID: projectionID,
            graphExportSHA256: graphExportSHA256,
            nodeCount: nodes.count,
            edgeCount: edges.count,
            ddlSHA256: ddlSHA256)
    } catch {
        try? database.execute("ROLLBACK")
        throw error
    }
}

private func disposalGraphExport(
    nodes: [DisposalGraphNodeRow],
    edges: [DisposalGraphEdgeRow],
    machine: DisposalMachineOverlay,
    stateClass: String,
    stateRuleID: String
) -> String {
    var data = Data("state\t\(stateRuleID)\t\(stateClass)\n".utf8)
    for node in nodes {
        data.append(contentsOf: [
            "node", node.id, node.kind, node.key, node.databaseRole, node.sourceRowID,
        ].joined(separator: "\t").utf8)
        data.append(0x0a)
    }
    for edge in edges {
        data.append(contentsOf: [
            "edge", edge.id, edge.from, edge.predicate, edge.to,
            edge.databaseRole, edge.sourceRowID, edge.pointer ?? "NULL", edge.grade,
        ].joined(separator: "\t").utf8)
        data.append(0x0a)
    }
    for state in machine.states.sorted(by: { $0.prefixOrdinal < $1.prefixOrdinal }) {
        data.append(contentsOf: [
            "machine_state", state.id, String(state.prefixOrdinal),
            state.predecessorID ?? "NULL", state.ancestrySHA256,
            state.highWaterFrameNodeID ?? "NULL", state.highWaterFrameLFSHA256 ?? "NULL",
            state.ruleID, state.predicateVectorSHA256, state.stateClass,
            state.derivedPostHocMerkleRootSHA256,
            String(state.derivedPostHocMerkleLeafCount),
        ].joined(separator: "\t").utf8)
        data.append(0x0a)
    }
    for witness in machine.witnesses.sorted(by: { $0.id < $1.id }) {
        data.append(contentsOf: [
            "machine_witness", witness.id, witness.table, witness.rowID,
            witness.exactRowSHA256, witness.normalizedFactSHA256,
            witness.sourceFrameNodeID ?? "NULL", String(witness.visibleOrdinal),
        ].joined(separator: "\t").utf8)
        data.append(0x0a)
    }
    for transition in machine.transitions.sorted(by: { $0.id < $1.id }) {
        data.append(contentsOf: [
            "machine_transition", transition.id, transition.fromStateID,
            transition.toStateID, transition.acceptedFrameNodeID,
            transition.acceptedFrameLFSHA256, transition.ruleID, transition.stateClass,
            transition.predicateVectorSHA256, transition.derivedPostHocSourceSetSHA256,
            transition.predecessorDerivedPostHocMerkleRootSHA256,
            String(transition.predecessorDerivedPostHocMerkleLeafCount),
            transition.preconservationMerkleCommitted,
            transition.preconservationCommitmentWitnessID ?? "NULL",
        ].joined(separator: "\t").utf8)
        data.append(0x0a)
        for predicate in transition.predicates.sorted(by: { $0.ordinal < $1.ordinal }) {
            data.append(contentsOf: [
                "machine_predicate", transition.id, String(predicate.ordinal),
                String(predicate.ruleOrdinal), predicate.ruleID,
                String(predicate.clauseOrdinal), predicate.clause, predicate.lhs,
                predicate.comparisonOperator, predicate.rhs, predicate.actualScalar,
                predicate.normalizedState, String(predicate.sourceCount),
                predicate.sourceSetSHA256, predicate.predicateSHA256,
            ].joined(separator: "\t").utf8)
            data.append(0x0a)
        }
    }
    for leaf in machine.merkleLeaves.sorted(by: {
        ($0.stateID, $0.ordinal) < ($1.stateID, $1.ordinal)
    }) {
        data.append(contentsOf: [
            "machine_merkle_leaf", leaf.stateID, String(leaf.ordinal), leaf.witnessID,
            leaf.normalizedLeafSHA256,
        ].joined(separator: "\t").utf8)
        data.append(0x0a)
    }
    for edge in machine.edges.sorted(by: { $0.id < $1.id }) {
        data.append(contentsOf: [
            "machine_overlay_edge", edge.id, edge.from, edge.to, edge.role,
        ].joined(separator: "\t").utf8)
        data.append(0x0a)
    }
    return disposalSHA256(data)
}
