import Foundation

public enum DisposalProjectionSetV1 {
    public static let evidenceLeaf = "disposal-evidence.v1.sqlite3"
    public static let metricsLeaf = "disposal-metrics.v1.sqlite3"
    public static let graphLeaf = "disposal-graph.v1.sqlite3"
    public static let sealLeaf = "disposal-set.v1.seal.json"
    public static let authorityVector = "00000000"

    public static func status(sourceSealed: Bool, terminal: Bool) -> String {
        terminal
            ? "PASS_NONAUTHORITATIVE_TERMINAL_PROJECTION"
            : (sourceSealed
                ? "ABSTAIN_SEALED_SOURCE_NO_DISPOSAL_TERMINAL"
                : "ABSTAIN_NONTERMINAL_PREFIX_PROJECTION")
    }
}

struct DisposalProjectionBuildTestingHooks {
    let afterPredecessorAdmission: (() throws -> Void)?
    let beforeSuccessorPublication: (() throws -> Void)?
}

public enum DisposalProjectionSetBuilder {
    public static func build(
        request: DisposalProjectionSetRequest,
        outputRootPath: String
    ) throws -> DisposalProjectionSetReport {
        try build(
            request: request,
            outputRootPath: outputRootPath,
            testingHooks: .init(
                afterPredecessorAdmission: nil,
                beforeSuccessorPublication: nil))
    }

    static func buildForTesting(
        request: DisposalProjectionSetRequest,
        outputRootPath: String,
        testingHooks: DisposalProjectionBuildTestingHooks
    ) throws -> DisposalProjectionSetReport {
        try build(
            request: request,
            outputRootPath: outputRootPath,
            testingHooks: testingHooks)
    }

    private static func build(
        request: DisposalProjectionSetRequest,
        outputRootPath: String,
        testingHooks: DisposalProjectionBuildTestingHooks
    ) throws -> DisposalProjectionSetReport {
        do {
            let journal = try DisposalProjectionSourceAdapter.decode(request.journal)
            let predecessor = try request.predecessor.map {
                try DisposalAdmittedPredecessor(
                    reference: $0,
                    successorJournal: journal,
                    successorLogicalPath: request.journalLogicalPath)
            }
            try testingHooks.afterPredecessorAdmission?()
            try predecessor?.revalidate()
            let materialRequest = DisposalProjectionMaterialRequest(
                journal: request.journal,
                journalLogicalPath: request.journalLogicalPath,
                recordedPredecessorProjectionID: predecessor?.projectionID)
            let material = try makeMaterial(
                request: materialRequest,
                decodedJournal: journal)
            try predecessor?.validateMachinePrefix(successorGraph: material.graph)
            try predecessor?.revalidate()
            let root = try DisposalSealedArtifactSet(path: outputRootPath)
            _ = try root.writeExclusive(
                leaf: DisposalProjectionSetV1.evidenceLeaf,
                data: material.evidence)
            _ = try root.writeExclusive(
                leaf: DisposalProjectionSetV1.metricsLeaf,
                data: material.metrics)
            _ = try root.writeExclusive(
                leaf: DisposalProjectionSetV1.graphLeaf,
                data: material.graph)
            _ = try root.writeExclusive(
                leaf: DisposalProjectionSetV1.sealLeaf,
                data: material.seal)
            try root.prepareForPublication(expectedLeaves: [
                DisposalProjectionSetV1.evidenceLeaf,
                DisposalProjectionSetV1.metricsLeaf,
                DisposalProjectionSetV1.graphLeaf,
                DisposalProjectionSetV1.sealLeaf,
            ])
            try testingHooks.beforeSuccessorPublication?()
            try root.publish(afterPreparedOutputRevalidation: {
                try predecessor?.revalidate()
            })
            return .init(
                outputRootPath: outputRootPath,
                evidencePath: outputRootPath + "/" + DisposalProjectionSetV1.evidenceLeaf,
                metricsPath: outputRootPath + "/" + DisposalProjectionSetV1.metricsLeaf,
                graphPath: outputRootPath + "/" + DisposalProjectionSetV1.graphLeaf,
                sealPath: outputRootPath + "/" + DisposalProjectionSetV1.sealLeaf,
                projectionID: material.projectionID,
                evidenceSHA256: material.evidenceSHA256,
                metricsSHA256: material.metricsSHA256,
                graphSHA256: material.graphSHA256,
                sealSHA256: material.sealSHA256,
                evidenceBytes: material.evidence.count,
                metricsBytes: material.metrics.count,
                graphBytes: material.graph.count,
                frameCount: material.frameCount,
                sourceSealed: material.sourceSealed,
                terminal: material.terminal,
                status: DisposalProjectionSetV1.status(
                    sourceSealed: material.sourceSealed,
                    terminal: material.terminal),
                authorityVector: "00000000")
        } catch let failure as DisposalSQLiteFailure {
            switch failure {
            case .rejected(let code, let detail):
                throw DisposalProjectionRejection(code: code, detail: detail)
            }
        }
    }

    static func makeMaterial(
        request: DisposalProjectionSetRequest
    ) throws -> DisposalProjectionSetMaterial {
        try disposalRequireProjection(
            request.predecessor == nil,
            "PREDECESSOR_REQUIRES_HELD_BUILD_ADMISSION")
        let journal = try DisposalProjectionSourceAdapter.decode(request.journal)
        return try makeMaterial(
            request: .init(
                journal: request.journal,
                journalLogicalPath: request.journalLogicalPath,
                recordedPredecessorProjectionID: nil),
            decodedJournal: journal)
    }

    static func makeMaterial(
        request: DisposalProjectionMaterialRequest,
        decodedJournal journal: DisposalDecodedJournal
    ) throws -> DisposalProjectionSetMaterial {
        let evidence = try buildDisposalEvidence(request: request, journal: journal)
        let metrics = try buildDisposalMetrics(journal: journal, evidence: evidence)
        let graph = try buildDisposalGraph(
            journal: journal,
            evidence: evidence,
            metrics: metrics)
        let projectionID = disposalID(
            "ergentics-disposal-projection-set-v1",
            [
                evidence.projectionID,
                evidence.databaseSHA256,
                metrics.projectionID,
                metrics.databaseSHA256,
                graph.projectionID,
                graph.databaseSHA256,
                request.recordedPredecessorProjectionID ?? "ABSENT",
            ])
        let seal = disposalProjectionSidecar(
            request: request,
            journal: journal,
            evidence: evidence,
            metrics: metrics,
            graph: graph,
            projectionID: projectionID)
        return .init(
            evidence: evidence.database,
            metrics: metrics.database,
            graph: graph.database,
            seal: seal,
            projectionID: projectionID,
            evidenceProjectionID: evidence.projectionID,
            metricsProjectionID: metrics.projectionID,
            graphProjectionID: graph.projectionID,
            evidenceSHA256: evidence.databaseSHA256,
            metricsSHA256: metrics.databaseSHA256,
            graphSHA256: graph.databaseSHA256,
            sealSHA256: disposalSHA256(seal),
            frameCount: journal.frames.count,
            sourceSealed: journal.sourceSealed,
            terminal: journal.isTerminal,
            invocationID: evidence.invocationID,
            epochLabel: evidence.epochLabel)
    }
}

private func disposalProjectionSidecar(
    request: DisposalProjectionMaterialRequest,
    journal: DisposalDecodedJournal,
    evidence: DisposalEvidenceMaterial,
    metrics: DisposalMetricsMaterial,
    graph: DisposalGraphMaterial,
    projectionID: String
) -> Data {
    let databaseObject = DisposalJSONValue.object([
        .init(key: "evidence", value: disposalDatabaseSidecarValue(
            applicationID: 1_162_105_649,
            bytes: evidence.database.count,
            projectionID: evidence.projectionID,
            relationalOrGraphSHA256: evidence.relationalExportSHA256,
            sha256: evidence.databaseSHA256)),
        .init(key: "graph", value: disposalDatabaseSidecarValue(
            applicationID: 1_162_102_577,
            bytes: graph.database.count,
            projectionID: graph.projectionID,
            relationalOrGraphSHA256: graph.graphExportSHA256,
            sha256: graph.databaseSHA256)),
        .init(key: "metrics", value: disposalDatabaseSidecarValue(
            applicationID: 1_162_104_113,
            bytes: metrics.database.count,
            projectionID: metrics.projectionID,
            relationalOrGraphSHA256: metrics.relationalExportSHA256,
            sha256: metrics.databaseSHA256)),
    ], disposalZeroSpan)
    let rulesObject = DisposalJSONValue.object([
        .init(key: "adapter_sha256", value: disposalJSONString(evidence.adapterSHA256)),
        .init(key: "evidence_ddl_sha256", value: disposalJSONString(evidence.ddlSHA256)),
        .init(key: "evidence_extractor_sha256", value: disposalJSONString(evidence.extractorSHA256)),
        .init(key: "graph_ddl_sha256", value: disposalJSONString(graph.ddlSHA256)),
        .init(key: "lattice_sha256", value: disposalJSONString(evidence.latticeSHA256)),
        .init(key: "metrics_ddl_sha256", value: disposalJSONString(metrics.ddlSHA256)),
        .init(key: "rational_math_sha256", value: disposalJSONString(metrics.rationalMathSHA256)),
    ], disposalZeroSpan)
    let sourceObject = DisposalJSONValue.object([
        .init(key: "bytes", value: disposalJSONNumber(journal.source.count)),
        .init(key: "frame_count", value: disposalJSONNumber(journal.frames.count)),
        .init(key: "high_water_frame_sha256", value: disposalJSONOptionalString(
            journal.frames.last?.rawWithLFSHA256)),
        .init(key: "is_source_sealed", value: disposalJSONBoolean(journal.sourceSealed)),
        .init(key: "is_terminal", value: disposalJSONBoolean(journal.isTerminal)),
        .init(key: "logical_path", value: disposalJSONString(request.journalLogicalPath)),
        .init(key: "sha256", value: disposalJSONString(journal.sourceSHA256)),
        .init(key: "source_kind", value: disposalJSONString(journal.sourceKind.rawValue)),
    ], disposalZeroSpan)
    return disposalCanonicalObject([
        "authoritative": disposalJSONBoolean(false),
        "authority_vector": disposalJSONString("00000000"),
        "databases": databaseObject,
        "may_feed_controller": disposalJSONBoolean(false),
        "predecessor_projection_id": disposalJSONOptionalString(
            request.recordedPredecessorProjectionID),
        "projection_id": disposalJSONString(projectionID),
        "prose_may_supply_fact": disposalJSONBoolean(false),
        "rules": rulesObject,
        "schema": disposalJSONString("ergentics_disposal_projection_set_sidecar_v1"),
        "source": sourceObject,
        "status": disposalJSONString(DisposalProjectionSetV1.status(
            sourceSealed: journal.sourceSealed,
            terminal: journal.isTerminal)),
        "unavailable_behavior": disposalJSONString(
            "EMPTY_OR_EXPLICIT_ABSTAIN_NO_STALE_FALLBACK"),
    ])
}

private func disposalDatabaseSidecarValue(
    applicationID: Int,
    bytes: Int,
    projectionID: String,
    relationalOrGraphSHA256: String,
    sha256: String
) -> DisposalJSONValue {
    .object([
        .init(key: "application_id", value: disposalJSONNumber(applicationID)),
        .init(key: "bytes", value: disposalJSONNumber(bytes)),
        .init(key: "export_sha256", value: disposalJSONString(relationalOrGraphSHA256)),
        .init(key: "projection_id", value: disposalJSONString(projectionID)),
        .init(key: "sha256", value: disposalJSONString(sha256)),
        .init(key: "user_version", value: disposalJSONNumber(1)),
    ], disposalZeroSpan)
}
