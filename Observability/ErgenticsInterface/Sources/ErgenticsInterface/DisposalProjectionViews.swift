import DisposalProjectionCore
import SwiftUI

private enum DisposalDestination: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case frames = "Frames"
    case process = "Process / TOCTOU"
    case metrics = "Metrics / energy"
    case graph = "Graph"
    case gaps = "Risks / missing"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .overview: "rectangle.grid.2x2"
        case .frames: "list.number"
        case .process: "point.topleft.down.to.point.bottomright.curvepath"
        case .metrics: "function"
        case .graph: "point.3.connected.trianglepath.dotted"
        case .gaps: "exclamationmark.triangle"
        }
    }
}

struct DisposalProjectionRootView: View {
    let availability: DisposalProjectionAvailability

    var body: some View {
        switch availability {
        case .empty:
            ContentUnavailableView {
                Label("No process projection loaded", systemImage: "tray")
            } description: {
                Text(
                    "No process state is inferred. Supply both the exact disposal " +
                    "projection root and external seal SHA-256 to admit a set.")
                    .frame(maxWidth: 580)
            }
        case .rejected(let rejection):
            VStack(spacing: 16) {
                Image(systemName: "xmark.shield")
                    .font(.system(size: 42))
                    .foregroundStyle(.red)
                Text("Process projection rejected")
                    .font(.title2.weight(.semibold))
                DisposalKeyValue(label: "Code", value: rejection.code)
                DisposalKeyValue(label: "Detail", value: rejection.detail)
                Text("No stale process, metric, or graph rows are displayed.")
                    .foregroundStyle(.secondary)
            }
            .padding(28)
        case .admitted(let snapshot):
            DisposalAdmittedView(snapshot: snapshot)
        }
    }
}

private struct DisposalAdmittedView: View {
    let snapshot: DisposalProjectionSnapshot
    @State private var destination: DisposalDestination? = .overview

    var body: some View {
        NavigationSplitView {
            List(DisposalDestination.allCases, selection: $destination) { value in
                Label(value.rawValue, systemImage: value.symbol).tag(value)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 280)
        } detail: {
            switch destination ?? .overview {
            case .overview: DisposalOverview(snapshot: snapshot)
            case .frames: DisposalFrames(rows: snapshot.frames)
            case .process: DisposalProcessRows(rows: snapshot.processRows)
            case .metrics: DisposalMetrics(rows: snapshot.metrics)
            case .graph:
                DisposalGraph(snapshot: snapshot)
            case .gaps:
                DisposalGaps(
                    windows: snapshot.riskWindows,
                    missing: snapshot.missingEvidence)
            }
        }
    }
}

private struct DisposalOverview: View {
    let snapshot: DisposalProjectionSnapshot

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 12),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Process evidence projection")
                            .font(.title2.weight(.semibold))
                        Text(snapshot.metadata.status)
                            .font(.callout.monospaced())
                            .foregroundStyle(snapshot.metadata.terminal ? .green : .orange)
                    }
                    Spacer()
                    Text(snapshot.metadata.authorityVector)
                        .font(.headline.monospaced())
                }
                LazyVGrid(columns: columns, spacing: 12) {
                    DisposalCountCard("Frames", snapshot.counts.frames)
                    DisposalCountCard("Process rows", snapshot.counts.processRows)
                    DisposalCountCard("Raw samples", snapshot.counts.samples)
                    DisposalCountCard("Metrics", snapshot.counts.metrics)
                    DisposalCountCard("Risk windows", snapshot.counts.riskWindows)
                    DisposalCountCard("Missing", snapshot.counts.missingEvidence)
                    DisposalCountCard("Graph nodes", snapshot.counts.graphNodes)
                    DisposalCountCard("Graph edges", snapshot.counts.graphEdges)
                    DisposalCountCard("Machine states", snapshot.counts.machineStates)
                    DisposalCountCard("Transitions", snapshot.counts.machineTransitions)
                    DisposalCountCard("Witnesses", snapshot.counts.machineWitnesses)
                    DisposalCountCard("Source Merkle sets", snapshot.counts.sourceConservationSets)
                    DisposalCountCard(
                        "Source memberships",
                        snapshot.counts.sourceConservationMemberships)
                    DisposalCountCard(
                        "Source proof nodes",
                        snapshot.counts.sourceConservationProofNodes)
                    DisposalCountCard(
                        "Source mappings",
                        snapshot.counts.sourceConservationMappings)
                    DisposalCountCard("Predicates", snapshot.counts.machinePredicates)
                }
                GroupBox("Exact admission identities") {
                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                        DisposalGridRow("Projection", snapshot.metadata.projectionID)
                        DisposalGridRow("Journal SHA-256", snapshot.metadata.sourceSHA256)
                        DisposalGridRow("Evidence SHA-256", snapshot.metadata.evidenceSHA256)
                        DisposalGridRow("Metrics SHA-256", snapshot.metadata.metricsSHA256)
                        DisposalGridRow("Graph SHA-256", snapshot.metadata.graphSHA256)
                        DisposalGridRow("Seal SHA-256", snapshot.metadata.sealSHA256)
                        DisposalGridRow(
                            "Predecessor",
                            snapshot.metadata.predecessorProjectionID ?? "ABSENT")
                    }
                    .padding(6)
                }
                Label {
                    Text(
                        "The interface renders copied, reconstructed, digest-joined bytes. " +
                        "It does not signal a process, feed a controller, or close Gate E.")
                } icon: {
                    Image(systemName: "eye")
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }
            .padding(20)
        }
        .navigationTitle("Process overview")
    }
}

private struct DisposalFrames: View {
    let rows: [DisposalFramePresentation]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DisposalHeader(
                title: "Canonical journal frames",
                detail: "Exact source order and hashes; no latest-wins rule.",
                count: rows.count)
            Table(rows) {
                TableColumn("#") { Text(String($0.ordinal)).monospacedDigit() }
                    .width(42)
                TableColumn("Event") { DisposalCell($0.eventType) }
                    .width(min: 90, ideal: 130)
                TableColumn("Phase") { DisposalCell($0.phase ?? "ABSENT") }
                    .width(min: 90, ideal: 150)
                TableColumn("Target") { DisposalCell($0.targetLabel ?? "ABSENT") }
                    .width(min: 100, ideal: 170)
                TableColumn("Status") { DisposalCell($0.status ?? "ABSENT") }
                    .width(min: 120, ideal: 220)
                TableColumn("Payload SHA-256") { DisposalCell($0.payloadSHA256) }
                    .width(min: 220, ideal: 420)
                TableColumn("Frame+LF SHA-256") { DisposalCell($0.rawWithLFSHA256) }
                    .width(min: 220, ideal: 420)
            }
        }
        .padding(20)
        .navigationTitle("Frames")
    }
}

private struct DisposalProcessRows: View {
    let rows: [DisposalProcessPresentation]
    @State private var selection: String?

    private var selected: DisposalProcessPresentation? {
        rows.first { $0.id == selection } ?? rows.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DisposalHeader(
                title: "Typed process and TOCTOU rows",
                detail: "Only exact-schema relational promotions appear here; raw-only frames remain absent or ABSTAIN.",
                count: rows.count)
            if rows.isEmpty {
                ContentUnavailableView(
                    "No typed process rows",
                    systemImage: "circle.dashed",
                    description: Text("The admitted prefix contains no promoted process evidence."))
            } else {
                HSplitView {
                    Table(rows, selection: $selection) {
                        TableColumn("Category") { DisposalCell($0.category) }
                            .width(min: 120, ideal: 170)
                        TableColumn("State") { DisposalCell($0.exactState) }
                            .width(min: 130, ideal: 220)
                        TableColumn("Target") { DisposalCell($0.targetID ?? "ABSENT") }
                            .width(min: 180, ideal: 300)
                        TableColumn("Source frame") { DisposalCell($0.sourceFrameID ?? "ABSENT") }
                            .width(min: 180, ideal: 300)
                    }
                    .frame(minWidth: 590)
                    if let selected {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                DisposalKeyValue(label: "Row", value: selected.id)
                                DisposalKeyValue(label: "Category", value: selected.category)
                                DisposalKeyValue(label: "State", value: selected.exactState)
                                ForEach(selected.fields) { field in
                                    DisposalKeyValue(
                                        label: field.key,
                                        value: field.value ?? "ABSENT")
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(minWidth: 330)
                    }
                }
            }
        }
        .padding(20)
        .navigationTitle("Process / TOCTOU")
        .onAppear { if selection == nil { selection = rows.first?.id } }
    }
}

private struct DisposalMetrics: View {
    let rows: [DisposalMetricPresentation]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DisposalHeader(
                title: "Exact rational CPU and qualified energy",
                detail: "Numerator/denominator lead. Approximations are display-only; premise and grade remain visible.",
                count: rows.count)
            Table(rows) {
                TableColumn("Metric") { DisposalCell($0.name) }
                    .width(min: 130, ideal: 210)
                TableColumn("Bound") { DisposalCell($0.bound) }
                    .width(min: 70, ideal: 95)
                TableColumn("Numerator") { DisposalCell($0.numerator) }
                    .width(min: 120, ideal: 200)
                TableColumn("Denominator") { DisposalCell($0.denominator) }
                    .width(min: 100, ideal: 160)
                TableColumn("Unit") { DisposalCell($0.unit) }
                    .width(min: 110, ideal: 190)
                TableColumn("Approximation") { DisposalCell($0.approximation ?? "ABSENT") }
                    .width(min: 110, ideal: 180)
                TableColumn("Premise") { DisposalCell($0.premise) }
                    .width(min: 190, ideal: 330)
                TableColumn("Evidence grade") { DisposalCell($0.sourceGrade) }
                    .width(min: 180, ideal: 300)
            }
        }
        .padding(20)
        .navigationTitle("Metrics / energy")
    }
}

private enum DisposalGraphTable: String, CaseIterable, Identifiable {
    case states = "States"
    case transitions = "Transitions"
    case predicates = "Predicates"
    case witnesses = "Witnesses"
    case merkle = "Merkle leaves"
    case machineEdges = "Bipartite edges"
    case sourceSets = "Source conservation sets"
    case sourceMemberships = "Set memberships"
    case sourceProofs = "Membership proofs"
    case sourceMappings = "Conservation mappings"
    case entityNodes = "Entity nodes"
    case entityEdges = "Entity edges"

    var id: String { rawValue }
}

private struct DisposalGraph: View {
    let snapshot: DisposalProjectionSnapshot
    @State private var table: DisposalGraphTable = .states

    private var selectedCount: Int {
        switch table {
        case .states: snapshot.machineStates.count
        case .transitions: snapshot.machineTransitions.count
        case .predicates: snapshot.machinePredicates.count
        case .witnesses: snapshot.machineWitnesses.count
        case .merkle: snapshot.machineMerkleLeaves.count
        case .machineEdges: snapshot.machineEdges.count
        case .sourceSets: snapshot.sourceConservationSets.count
        case .sourceMemberships: snapshot.sourceConservationMemberships.count
        case .sourceProofs: snapshot.sourceConservationProofNodes.count
        case .sourceMappings: snapshot.sourceConservationMappings.count
        case .entityNodes: snapshot.graphNodes.count
        case .entityEdges: snapshot.graphEdges.count
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                DisposalHeader(
                    title: "Content-addressed state machine",
                    detail: "Object={state,witness}; relation={transition}. Derived prefix integrity and exact predecessor-visible source commitments are distinct, non-authoritative facts.",
                    count: selectedCount)
                Spacer()
                Picker("Graph table", selection: $table) {
                    ForEach(DisposalGraphTable.allCases) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                .frame(width: 210)
            }
            switch table {
            case .states:
                Table(snapshot.machineStates) {
                    TableColumn("Prefix") { Text(String($0.prefixOrdinal)).monospacedDigit() }
                        .width(60)
                    TableColumn("Class") { DisposalCell($0.stateClass) }
                        .width(min: 160, ideal: 270)
                    TableColumn("Rule") { DisposalCell($0.matchedRuleID) }
                        .width(60)
                    TableColumn("State SHA-256") { DisposalCell($0.id) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Ancestry SHA-256") { DisposalCell($0.ancestrySHA256) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Derived post-hoc witness Merkle root") {
                        DisposalCell($0.derivedWitnessMerkleRootSHA256)
                    }
                    .width(min: 220, ideal: 400)
                    TableColumn("Leaves") { Text(String($0.derivedWitnessLeafCount)).monospacedDigit() }
                        .width(60)
                }
            case .transitions:
                Table(snapshot.machineTransitions) {
                    TableColumn("Rule") { DisposalCell($0.matchedRuleID) }
                        .width(60)
                    TableColumn("Class") { DisposalCell($0.stateClass) }
                        .width(min: 160, ideal: 270)
                    TableColumn("From") { DisposalCell($0.fromStateID) }
                        .width(min: 190, ideal: 320)
                    TableColumn("To") { DisposalCell($0.toStateID) }
                        .width(min: 190, ideal: 320)
                    TableColumn("Predicate vector") { DisposalCell($0.predicateVectorSHA256) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Exact predecessor-visible source commitment") {
                        DisposalCell($0.preconservationMerkleCommitted)
                    }
                    .width(min: 190, ideal: 280)
                    TableColumn("Source commitment witness") {
                        DisposalCell($0.preconservationCommitmentWitnessID ?? "ABSENT")
                    }
                    .width(min: 220, ideal: 400)
                }
            case .predicates:
                Table(snapshot.machinePredicates) {
                    TableColumn("Rule") { DisposalCell($0.ruleID) }
                        .width(58)
                    TableColumn("Predicate") { DisposalCell($0.clause) }
                        .width(min: 240, ideal: 390)
                    TableColumn("Actual") { DisposalCell($0.actualScalar) }
                        .width(min: 100, ideal: 180)
                    TableColumn("Truth") { DisposalCell($0.normalizedState) }
                        .width(min: 75, ideal: 100)
                    TableColumn("Sources") { Text(String($0.sourceCount)).monospacedDigit() }
                        .width(68)
                    TableColumn("Source-set SHA-256") { DisposalCell($0.sourceSetSHA256) }
                        .width(min: 220, ideal: 400)
                }
            case .witnesses:
                Table(snapshot.machineWitnesses) {
                    TableColumn("At prefix") { Text(String($0.visiblePrefixOrdinal)).monospacedDigit() }
                        .width(68)
                    TableColumn("Kind") { DisposalCell($0.kind) }
                        .width(min: 150, ideal: 260)
                    TableColumn("Witness SHA-256") { DisposalCell($0.id) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Normalized fact") { DisposalCell($0.normalizedFactSHA256) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Exact source-row SHA-256") { DisposalCell($0.exactRowSHA256) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Intrinsic source frame LF SHA-256") {
                        DisposalCell($0.intrinsicSourceFrameLFSHA256 ?? "ABSENT")
                    }
                    .width(min: 220, ideal: 400)
                    TableColumn("Source frame node") {
                        DisposalCell($0.sourceFrameNodeID ?? "ABSENT")
                    }
                    .width(min: 220, ideal: 400)
                    TableColumn("Source row") { DisposalCell($0.sourceRowID) }
                        .width(min: 190, ideal: 320)
                }
            case .merkle:
                Table(snapshot.machineMerkleLeaves) {
                    TableColumn("Leaf") { Text(String($0.leafOrdinal)).monospacedDigit() }
                        .width(58)
                    TableColumn("State") { DisposalCell($0.stateID) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Witness") { DisposalCell($0.witnessID) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Leaf SHA-256") { DisposalCell($0.normalizedLeafSHA256) }
                        .width(min: 220, ideal: 400)
                }
            case .machineEdges:
                Table(snapshot.machineEdges) {
                    TableColumn("Role") { DisposalCell($0.role) }
                        .width(min: 90, ideal: 130)
                    TableColumn("From") { DisposalCell($0.fromNodeID) }
                        .width(min: 220, ideal: 400)
                    TableColumn("To") { DisposalCell($0.toNodeID) }
                        .width(min: 220, ideal: 400)
                }
            case .sourceSets:
                Table(snapshot.sourceConservationSets) {
                    TableColumn("Temporal state") { DisposalCell($0.temporalState) }
                        .width(min: 160, ideal: 240)
                    TableColumn("Source frame LF SHA-256") {
                        DisposalCell($0.sourceFrameLFSHA256)
                    }
                    .width(min: 220, ideal: 400)
                    TableColumn("Committed root SHA-256") { DisposalCell($0.witnessRootSHA256) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Leaves") { Text(String($0.leafCount)).monospacedDigit() }
                        .width(60)
                    TableColumn("Scope") { DisposalCell($0.scopeKind + ":" + $0.scopeID) }
                        .width(min: 230, ideal: 420)
                    TableColumn("Algorithm / tree") {
                        DisposalCell($0.algorithm + " / " + $0.treeShape)
                    }
                    .width(min: 220, ideal: 410)
                    TableColumn("Domain") { DisposalCell($0.domainTag) }
                        .width(min: 220, ideal: 380)
                    TableColumn("Ordering") { DisposalCell($0.leafOrdering) }
                        .width(min: 190, ideal: 320)
                    TableColumn("Duplicate / odd-leaf policy") {
                        DisposalCell($0.duplicatePolicy + " / " + $0.oddLeafRule)
                    }
                    .width(min: 230, ideal: 420)
                    TableColumn("Set ID") { DisposalCell($0.id) }
                        .width(min: 220, ideal: 400)
                }
            case .sourceMemberships:
                Table(snapshot.sourceConservationMemberships) {
                    TableColumn("Leaf") { Text(String($0.leafOrdinal)).monospacedDigit() }
                        .width(58)
                    TableColumn("Role") { DisposalCell($0.targetRole) }
                        .width(min: 120, ideal: 210)
                    TableColumn("Operation") {
                        DisposalCell($0.operation + " " + String($0.numericArgument))
                    }
                    .width(min: 110, ideal: 180)
                    TableColumn("Obligation key SHA-256") { DisposalCell($0.obligationKeySHA256) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Leaf SHA-256") { DisposalCell($0.leafSHA256) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Proof SHA-256 / depth") {
                        DisposalCell($0.proofSHA256 + " / " + String($0.proofDepth))
                    }
                    .width(min: 220, ideal: 420)
                    TableColumn("Commitment frame LF SHA-256") {
                        DisposalCell($0.commitmentFrameLFSHA256)
                    }
                    .width(min: 220, ideal: 400)
                }
            case .sourceMappings:
                Table(snapshot.sourceConservationMappings) {
                    TableColumn("Mapping") { DisposalCell($0.mappingState) }
                        .width(min: 150, ideal: 250)
                    TableColumn("Merkle") { DisposalCell($0.merkleState) }
                        .width(min: 150, ideal: 250)
                    TableColumn("Conservation") {
                        DisposalCell($0.conservationCompletionState)
                    }
                    .width(min: 110, ideal: 180)
                    TableColumn("Membership") { DisposalCell($0.membershipID) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Conservation frame LF SHA-256") {
                        DisposalCell($0.conservationSourceFrameLFSHA256)
                    }
                    .width(min: 220, ideal: 400)
                    TableColumn("Mapping ID") { DisposalCell($0.id) }
                        .width(min: 220, ideal: 400)
                }
            case .sourceProofs:
                Table(snapshot.sourceConservationProofNodes) {
                    TableColumn("Step") { Text(String($0.proofOrdinal)).monospacedDigit() }
                        .width(58)
                    TableColumn("Sibling position") { DisposalCell($0.siblingPosition) }
                        .width(min: 100, ideal: 150)
                    TableColumn("Sibling SHA-256") { DisposalCell($0.siblingSHA256) }
                        .width(min: 220, ideal: 400)
                    TableColumn("Membership") { DisposalCell($0.membershipID) }
                        .width(min: 220, ideal: 400)
                }
            case .entityEdges:
                Table(snapshot.graphEdges) {
                    TableColumn("Predicate") { DisposalCell($0.predicate) }
                        .width(min: 150, ideal: 240)
                    TableColumn("From") { DisposalCell($0.fromNodeID) }
                        .width(min: 190, ideal: 320)
                    TableColumn("To") { DisposalCell($0.toNodeID) }
                        .width(min: 190, ideal: 320)
                    TableColumn("Grade") { DisposalCell($0.evidenceGrade) }
                        .width(min: 160, ideal: 260)
                    TableColumn("Source row") { DisposalCell($0.sourceRowID) }
                        .width(min: 190, ideal: 320)
                }
            case .entityNodes:
                Table(snapshot.graphNodes) {
                    TableColumn("Kind") { DisposalCell($0.kind) }
                        .width(min: 110, ideal: 160)
                    TableColumn("Key") { DisposalCell($0.canonicalKey) }
                        .width(min: 190, ideal: 340)
                    TableColumn("Label") { DisposalCell($0.label) }
                        .width(min: 150, ideal: 260)
                    TableColumn("Source") { DisposalCell($0.sourceDatabaseRole) }
                        .width(min: 80, ideal: 110)
                    TableColumn("Row") { DisposalCell($0.sourceRowID) }
                        .width(min: 190, ideal: 320)
                }
            }
        }
        .padding(20)
        .navigationTitle("State / evidence graph")
    }
}

private struct DisposalGaps: View {
    let windows: [DisposalRiskWindowPresentation]
    let missing: [DisposalMissingEvidencePresentation]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            DisposalHeader(
                title: "Named risk windows",
                detail: "Closure state is data. A bound or qualification does not erase the residual.",
                count: windows.count)
            Table(windows) {
                TableColumn("Kind") { DisposalCell($0.kind) }
                    .width(min: 180, ideal: 310)
                TableColumn("Basis") { DisposalCell($0.basis) }
                    .width(min: 120, ideal: 190)
                TableColumn("Closure") { DisposalCell($0.closureState) }
                    .width(min: 160, ideal: 270)
                TableColumn("Maximum ns") { DisposalCell($0.maximumDurationNanoseconds ?? "ABSENT") }
                    .width(min: 100, ideal: 150)
                TableColumn("Qualification") { DisposalCell($0.qualification) }
                    .width(min: 220, ideal: 420)
            }
            .frame(minHeight: 220)
            Divider()
            DisposalHeader(
                title: "Explicit missing evidence",
                detail: "Missing evidence is ABSTAIN; no prose or stale projection fills it.",
                count: missing.count)
            Table(missing) {
                TableColumn("Evidence") { DisposalCell($0.evidenceKind) }
                    .width(min: 160, ideal: 260)
                TableColumn("Target role") { DisposalCell($0.targetRole ?? "ABSENT") }
                    .width(min: 110, ideal: 170)
                TableColumn("Reason") { DisposalCell($0.reasonCode) }
                    .width(min: 160, ideal: 290)
                TableColumn("State") { DisposalCell($0.valueState) }
                    .width(min: 70, ideal: 100)
                TableColumn("Source frame") { DisposalCell($0.sourceFrameID ?? "ABSENT") }
                    .width(min: 190, ideal: 330)
            }
            .frame(minHeight: 180)
        }
        .padding(20)
        .navigationTitle("Risks / missing")
    }
}

private struct DisposalCountCard: View {
    let label: String
    let value: Int

    init(_ label: String, _ value: Int) {
        self.label = label
        self.value = value
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(String(value)).font(.title2.weight(.semibold).monospacedDigit())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 9))
    }
}

private struct DisposalHeader: View {
    let title: String
    let detail: String
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline) {
                Text(title).font(.title2.weight(.semibold))
                Spacer()
                Text("\(count) rows")
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Text(detail).font(.callout).foregroundStyle(.secondary)
        }
    }
}

private struct DisposalCell: View {
    let value: String

    init(_ value: String) { self.value = value }

    var body: some View {
        Text(value)
            .font(.caption.monospaced())
            .lineLimit(2)
            .textSelection(.enabled)
            .help(value)
    }
}

private struct DisposalKeyValue: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value).font(.caption.monospaced()).textSelection(.enabled)
        }
    }
}

private struct DisposalGridRow: View {
    let label: String
    let value: String

    init(_ label: String, _ value: String) {
        self.label = label
        self.value = value
    }

    var body: some View {
        GridRow {
            Text(label).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            Text(value).font(.caption.monospaced()).textSelection(.enabled)
        }
    }
}
