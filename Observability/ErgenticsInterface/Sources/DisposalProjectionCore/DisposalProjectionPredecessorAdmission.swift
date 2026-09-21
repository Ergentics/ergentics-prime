import Foundation

final class DisposalAdmittedPredecessor {
    private let validated: DisposalValidatedProjection

    var projectionID: String { validated.snapshot.metadata.projectionID }

    init(
        reference: DisposalProjectionPredecessorReference,
        successorJournal: DisposalDecodedJournal,
        successorLogicalPath: String,
        resources: DisposalProjectionRuleResources
    ) throws {
        do {
            validated = try DisposalProjectionReader.validateExact(
                rootPath: reference.rootPath,
                expectedSealSHA256: reference.expectedSealSHA256,
                resources: resources)
        } catch is DisposalProjectionMissing {
            throw DisposalProjectionRejection(code: "PREDECESSOR_ROOT_MISSING")
        }

        let predecessor = validated.journal
        try disposalRequireProjection(
            !predecessor.sourceSealed && !predecessor.isTerminal,
            "PREDECESSOR_NOT_APPENDABLE")
        try disposalRequireProjection(
            predecessor.sourceKind == successorJournal.sourceKind,
            "PREDECESSOR_SOURCE_KIND_JOIN")
        try disposalRequireProjection(
            validated.logicalPath == successorLogicalPath,
            "PREDECESSOR_LOGICAL_PATH_JOIN")
        let successorIdentity = try DisposalProjectionSourceAdapter.identity(
            of: successorJournal)
        try disposalRequireProjection(
            validated.identity.invocationID == successorIdentity.invocationID,
            "PREDECESSOR_INVOCATION_JOIN")
        try disposalRequireProjection(
            validated.identity.epochLabel == successorIdentity.epochLabel,
            "PREDECESSOR_EPOCH_JOIN")
        try disposalRequireProjection(
            successorJournal.frames.count > predecessor.frames.count,
            "PREDECESSOR_STRICT_EXTENSION")
        try disposalRequireProjection(
            successorJournal.source.starts(with: predecessor.source),
            "PREDECESSOR_SOURCE_PREFIX_JOIN")
        guard let predecessorHighWater = predecessor.frames.last?.rawWithLFSHA256 else {
            throw DisposalProjectionRejection(code: "PREDECESSOR_HIGH_WATER_ABSENT")
        }
        try disposalRequireProjection(
            validated.highWaterFrameLFSHA256 == predecessorHighWater &&
                successorJournal.frames[predecessor.frames.count - 1].rawWithLFSHA256 ==
                    predecessorHighWater,
            "PREDECESSOR_HIGH_WATER_JOIN")
        try disposalRequireProjection(
            successorJournal.frames[predecessor.frames.count].previousSHA256 ==
                predecessorHighWater,
            "PREDECESSOR_NEXT_FRAME_JOIN")
        try validated.held.revalidate()
    }

    func revalidate() throws {
        try validated.held.revalidate()
    }

    func validateMachinePrefix(successorGraph: Data) throws {
        let predecessor = try DisposalSQLiteConnection(
            serializedReadOnly: validated.held.graph)
        defer { try? predecessor.close() }
        let successor = try DisposalSQLiteConnection(serializedReadOnly: successorGraph)
        defer { try? successor.close() }
        let maximumPrefixOrdinal = validated.journal.frames.count - 1
        let ordinal = String(maximumPrefixOrdinal)
        let comparisons: [(String, String, Int, String)] = [
            (
                "SELECT * FROM machine_nodes ORDER BY machine_node_id",
                "SELECT * FROM machine_nodes WHERE machine_node_id IN (" +
                    "SELECT state_id FROM machine_states WHERE prefix_ordinal<=" + ordinal +
                    " UNION SELECT t.transition_id FROM machine_transitions t " +
                    "JOIN machine_states s ON s.state_id=t.to_state_id " +
                    "WHERE s.prefix_ordinal<=" + ordinal +
                    " UNION SELECT witness_id FROM machine_witnesses " +
                    "WHERE visible_prefix_ordinal<=" + ordinal +
                    ") ORDER BY machine_node_id",
                5,
                "NODES"),
            (
                "SELECT * FROM machine_states ORDER BY prefix_ordinal",
                "SELECT * FROM machine_states WHERE prefix_ordinal<=" + ordinal +
                    " ORDER BY prefix_ordinal",
                18,
                "STATES"),
            (
                "SELECT * FROM machine_state_bindings ORDER BY state_id",
                "SELECT b.* FROM machine_state_bindings b " +
                    "JOIN machine_states s ON s.state_id=b.state_id " +
                    "WHERE s.prefix_ordinal<=" + ordinal + " ORDER BY b.state_id",
                3,
                "STATE_BINDINGS"),
            (
                "SELECT * FROM machine_transitions ORDER BY transition_id",
                "SELECT t.* FROM machine_transitions t " +
                    "JOIN machine_states s ON s.state_id=t.to_state_id " +
                    "WHERE s.prefix_ordinal<=" + ordinal + " ORDER BY t.transition_id",
                15,
                "TRANSITIONS"),
            (
                "SELECT * FROM machine_transition_bindings ORDER BY transition_id",
                "SELECT b.* FROM machine_transition_bindings b " +
                    "JOIN machine_transitions t ON t.transition_id=b.transition_id " +
                    "JOIN machine_states s ON s.state_id=t.to_state_id " +
                    "WHERE s.prefix_ordinal<=" + ordinal + " ORDER BY b.transition_id",
                2,
                "TRANSITION_BINDINGS"),
            (
                "SELECT * FROM machine_transition_predicates " +
                    "ORDER BY transition_id,predicate_ordinal",
                "SELECT p.* FROM machine_transition_predicates p " +
                    "JOIN machine_transitions t ON t.transition_id=p.transition_id " +
                    "JOIN machine_states s ON s.state_id=t.to_state_id " +
                    "WHERE s.prefix_ordinal<=" + ordinal +
                    " ORDER BY p.transition_id,p.predicate_ordinal",
                14,
                "PREDICATES"),
            (
                "SELECT * FROM machine_witnesses ORDER BY witness_id",
                "SELECT * FROM machine_witnesses WHERE visible_prefix_ordinal<=" + ordinal +
                    " ORDER BY witness_id",
                7,
                "WITNESSES"),
            (
                "SELECT * FROM machine_witness_bindings ORDER BY witness_id",
                "SELECT b.* FROM machine_witness_bindings b " +
                    "JOIN machine_witnesses w ON w.witness_id=b.witness_id " +
                    "WHERE w.visible_prefix_ordinal<=" + ordinal + " ORDER BY b.witness_id",
                6,
                "WITNESS_BINDINGS"),
            (
                "SELECT * FROM machine_merkle_leaves ORDER BY state_id,leaf_ordinal",
                "SELECT l.* FROM machine_merkle_leaves l " +
                    "JOIN machine_states s ON s.state_id=l.state_id " +
                    "WHERE s.prefix_ordinal<=" + ordinal +
                    " ORDER BY l.state_id,l.leaf_ordinal",
                4,
                "MERKLE_LEAVES"),
        ]
        for (predecessorSQL, successorSQL, columns, label) in comparisons {
            let predecessorResult = try predecessorRows(
                predecessor, predecessorSQL, columns: columns)
            let successorResult = try predecessorRows(
                successor, successorSQL, columns: columns)
            try disposalRequireProjection(
                predecessorResult == successorResult,
                "PREDECESSOR_MACHINE_PREFIX_DRIFT",
                detail: label)
        }

        let allowed =
            "SELECT state_id AS node_id FROM machine_states WHERE prefix_ordinal<=" + ordinal +
            " UNION SELECT t.transition_id FROM machine_transitions t " +
            "JOIN machine_states s ON s.state_id=t.to_state_id WHERE s.prefix_ordinal<=" + ordinal +
            " UNION SELECT witness_id FROM machine_witnesses WHERE visible_prefix_ordinal<=" +
            ordinal
        let successorOverlay =
            "WITH allowed AS (" + allowed + ") " +
            "SELECT e.* FROM machine_overlay_edges e " +
            "WHERE e.from_node_id IN (SELECT node_id FROM allowed) " +
            "AND e.to_node_id IN (SELECT node_id FROM allowed) " +
            "ORDER BY e.overlay_edge_id"
        try disposalRequireProjection(
            try predecessorRows(
                predecessor,
                "SELECT * FROM machine_overlay_edges ORDER BY overlay_edge_id",
                columns: 6) ==
                predecessorRows(successor, successorOverlay, columns: 6),
            "PREDECESSOR_MACHINE_PREFIX_DRIFT",
            detail: "OVERLAY_EDGES")
    }

    private func predecessorRows(
        _ database: DisposalSQLiteConnection,
        _ sql: String,
        columns: Int
    ) throws -> [[String?]] {
        let statement = try database.prepare(sql)
        var result: [[String?]] = []
        while try statement.step() {
            result.append((0..<columns).map { statement.optionalText(Int32($0)) })
        }
        return result
    }
}
