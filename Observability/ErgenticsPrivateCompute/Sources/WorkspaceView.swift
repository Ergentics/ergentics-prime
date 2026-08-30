import AppKit
import Foundation
import SwiftUI

private enum LabPalette {
    static let background = Color(red: 0.055, green: 0.069, blue: 0.080)
    static let sidebar = Color(red: 0.069, green: 0.086, blue: 0.096)
    static let panel = Color(red: 0.083, green: 0.105, blue: 0.116)
    static let inset = Color(red: 0.064, green: 0.084, blue: 0.094)
    static let line = Color.white.opacity(0.085)
    static let text = Color(red: 0.89, green: 0.93, blue: 0.93)
    static let muted = Color(red: 0.53, green: 0.63, blue: 0.65)
    static let teal = Color(red: 0.35, green: 0.86, blue: 0.75)
    static let amber = Color(red: 0.94, green: 0.72, blue: 0.39)
    static let red = Color(red: 0.98, green: 0.52, blue: 0.48)
}

private enum WorkspaceSection: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case graph = "Joined graph"
    case receipts = "Receipts"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .overview: "square.grid.2x2"
        case .graph: "circle.hexagongrid"
        case .receipts: "doc.text"
        }
    }
}

@MainActor
struct WorkspaceView: View {
    @ObservedObject var model: ComputeModel
    @State private var selection: WorkspaceSection = .overview

    // Presentation only. The model owns validation; this decoder grants no authority.
    private var displayedGraph: DisplayGraph? {
        guard model.mathematicalPass, let data = model.graphData else { return nil }
        return try? DisplayGraph(data: data)
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Rectangle().fill(LabPalette.line).frame(width: 1)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    switch selection {
                    case .overview:
                        outcomePanel
                        streamPanels
                        graphPanel
                        commitmentsPanel
                    case .graph:
                        graphPanel
                        commitmentsPanel
                        scopePanel
                    case .receipts:
                        persistencePanel
                        receiptsPanel
                        commitmentsPanel
                    }
                    footer
                }
                .padding(26)
                .frame(maxWidth: 1180, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background(LabPalette.background)
        }
        .foregroundStyle(LabPalette.text)
        .background(LabPalette.background)
        .tint(LabPalette.teal)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "cube.transparent")
                    .font(.system(size: 25, weight: .light))
                    .foregroundStyle(LabPalette.teal)
                VStack(alignment: .leading, spacing: 3) {
                    Text("ERGENTICS").font(.system(size: 12, weight: .semibold)).tracking(2)
                    Text("Private Compute").font(.system(size: 10)).foregroundStyle(LabPalette.muted)
                }
            }
            .padding(.top, 27)
            .padding(.bottom, 37)

            eyebrow("WORKSPACE").padding(.bottom, 13)
            VStack(spacing: 5) {
                ForEach(WorkspaceSection.allCases) { section in
                    Button {
                        selection = section
                    } label: {
                        HStack(spacing: 11) {
                            Image(systemName: section.symbol).frame(width: 17)
                            Text(section.rawValue).font(.system(size: 12, weight: .medium))
                            Spacer(minLength: 0)
                            if section == .receipts {
                                Text(String(model.artifactRows.count))
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(LabPalette.muted)
                            }
                        }
                        .foregroundStyle(selection == section ? LabPalette.teal : LabPalette.muted)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 11)
                        .background(selection == section ? LabPalette.teal.opacity(0.09) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, -10)

            Spacer(minLength: 35)
            VStack(alignment: .leading, spacing: 12) {
                eyebrow("EXECUTION BOUNDARY")
                Label("In-process computation", systemImage: "cpu")
                Label("App Sandbox", systemImage: "lock.shield")
                Label("No network capability", systemImage: "network.slash")
            }
            .font(.system(size: 10.5))
            .foregroundStyle(LabPalette.muted)
            .padding(.bottom, 24)
            Rectangle().fill(LabPalette.line).frame(height: 1)
            VStack(alignment: .leading, spacing: 10) {
                statusPill("GATE E · ABSTAIN", color: LabPalette.amber)
                Text("00000000")
                    .font(.system(size: 17, weight: .light, design: .monospaced))
                    .tracking(3)
                Text("No live Git or Swift probes.\nNo execution authority advanced.")
                    .font(.system(size: 10.5))
                    .foregroundStyle(LabPalette.muted)
                    .lineSpacing(4)
            }
            .padding(.top, 22)
            .padding(.bottom, 26)
        }
        .padding(.horizontal, 22)
        .frame(width: 210)
        .background(LabPalette.sidebar)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 7) {
                eyebrow("LOCAL LAB / STATIC COMPUTATION")
                Text(selection == .overview ? "Private compute" : selection.rawValue)
                    .font(.system(size: 28, weight: .semibold))
                    .tracking(-0.7)
                Text("Two independent carriers. One verified graph.")
                    .font(.system(size: 12))
                    .foregroundStyle(LabPalette.muted)
            }
            Spacer(minLength: 12)
            statusPill("LOCAL · OFFLINE", color: LabPalette.teal)
                .padding(.top, 5)
        }
    }

    private var outcomePanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(outcomeColor.opacity(0.10))
                    if model.isRunning {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: model.mathematicalPass ? "checkmark.shield" : "shield.lefthalf.filled")
                            .font(.system(size: 22, weight: .light))
                            .foregroundStyle(outcomeColor)
                    }
                }
                .frame(width: 49, height: 49)
                VStack(alignment: .leading, spacing: 6) {
                    Text(outcomeTitle).font(.system(size: 18, weight: .medium))
                    Text(model.detail)
                        .font(.system(size: 11.5))
                        .foregroundStyle(LabPalette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(model.status)
                        .font(.system(size: 9.5, design: .monospaced))
                        .foregroundStyle(outcomeColor)
                        .textSelection(.enabled)
                }
                Spacer(minLength: 0)
            }
            Rectangle().fill(LabPalette.line).frame(height: 1)
            HStack(alignment: .top, spacing: 22) {
                summaryMetric("MATHEMATICAL PROOF", value: model.mathematicalPass ? "STATIC PASS" : "Not established", color: model.mathematicalPass ? LabPalette.teal : LabPalette.muted)
                summaryMetric("LOCAL RECEIPT", value: model.persistencePass ? "Saved & verified" : "Not complete", color: model.persistencePass ? LabPalette.teal : LabPalette.muted)
                summaryMetric("INTERVAL", value: model.elapsedText.isEmpty ? "—" : model.elapsedText, color: LabPalette.text)
                summaryMetric("ENERGY · ERGS", value: "Not measured", color: LabPalette.muted)
            }
            if let error = model.errorText {
                Label(error, systemImage: "exclamationmark.triangle")
                    .font(.system(size: 11))
                    .foregroundStyle(LabPalette.red)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .labPanel()
    }

    private var outcomeTitle: String {
        if model.mathematicalPass { return "Static computation passed" }
        if model.isRunning { return "Computing the fixed proof" }
        if model.errorText != nil { return "Run stopped" }
        return "Preparing local workspace"
    }

    private var outcomeColor: Color {
        if model.mathematicalPass { return LabPalette.teal }
        if model.errorText != nil { return LabPalette.red }
        return LabPalette.amber
    }

    private var streamPanels: some View {
        HStack(alignment: .top, spacing: 12) {
            streamPanel("01", title: "JSON authority", subtitle: "Canonical JSON → graph", footnote: "Independent reconstruction")
            streamPanel("02", title: "CBOR authority", subtitle: "Canonical CBOR → graph", footnote: "Separate carrier and decoder")
            streamPanel("03", title: "Independent join", subtitle: "Graph + receipts → agreement", footnote: "Merkle and semantic checks")
        }
    }

    private func streamPanel(_ ordinal: String, title: String, subtitle: String, footnote: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(ordinal).font(.system(size: 10, design: .monospaced)).foregroundStyle(LabPalette.muted)
                Spacer()
                Image(systemName: model.mathematicalPass ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(model.mathematicalPass ? LabPalette.teal : LabPalette.muted)
                    .font(.system(size: 12))
            }
            Text(title).font(.system(size: 12, weight: .semibold))
            Text(subtitle).font(.system(size: 10)).foregroundStyle(LabPalette.muted)
            Text(footnote).font(.system(size: 9)).foregroundStyle(LabPalette.muted.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .labPanel()
    }

    @ViewBuilder
    private var graphPanel: some View {
        if let graph = displayedGraph {
            JoinedGraphPanel(graph: graph)
        } else {
            VStack(alignment: .leading, spacing: 14) {
                panelHeading("Joined graph", subtitle: "State · transition · witness")
                VStack(spacing: 13) {
                    Image(systemName: "circle.hexagongrid")
                        .font(.system(size: 34, weight: .ultraLight))
                        .foregroundStyle(LabPalette.muted)
                    Text(model.mathematicalPass && model.graphData != nil ? "Graph display could not be decoded" : "Awaiting an accepted joined graph")
                        .font(.system(size: 12))
                    Text("Only validated output is drawn here. Retained bytes remain unchanged.")
                        .font(.system(size: 10))
                        .foregroundStyle(LabPalette.muted)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 170)
                .background(LabPalette.inset)
                .clipShape(RoundedRectangle(cornerRadius: 9))
            }
            .padding(20)
            .labPanel()
        }
    }

    private var commitmentsPanel: some View {
        VStack(alignment: .leading, spacing: 17) {
            panelHeading("Content commitments", subtitle: "Exact identifiers from the accepted result")
            commitmentRow("GRAPH MERKLE ROOT", value: model.merkleRoot)
            commitmentRow("SEMANTIC ROOT", value: model.semanticRoot)
            commitmentRow("GRAPH FRAME · SHA-256", value: model.graphHash)
        }
        .padding(20)
        .labPanel()
    }

    private var persistencePanel: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                panelHeading("Retained local evidence", subtitle: "Fresh app-private run · no overwrite or automatic retry")
                Spacer()
                statusPill(model.persistencePass ? "SAVED" : "INCOMPLETE", color: model.persistencePass ? LabPalette.teal : LabPalette.amber)
            }
            Text(model.runPath.isEmpty ? "No retained run path is available yet." : model.runPath)
                .font(.system(size: 10.5, design: .monospaced))
                .foregroundStyle(LabPalette.muted)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
            if !model.runPath.isEmpty {
                Button {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: model.runPath)
                } label: {
                    Label("Reveal receipt folder", systemImage: "folder")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            Text("Local retention is not an encrypted vault or a remote archival backup.")
                .font(.system(size: 10))
                .foregroundStyle(LabPalette.muted)
        }
        .padding(20)
        .labPanel()
    }

    private var receiptsPanel: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack {
                panelHeading("Raw artifacts", subtitle: "Original bytes, independent receipts and terminal manifest")
                Spacer()
                Text("\(model.artifactRows.count) retained")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(LabPalette.muted)
            }
            if model.artifactRows.isEmpty {
                Text("No artifact inventory has been returned.")
                    .font(.system(size: 12))
                    .foregroundStyle(LabPalette.muted)
                    .padding(.vertical, 20)
            } else {
                ForEach(model.artifactRows) { row in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 9) {
                            Image(systemName: "doc.plaintext").foregroundStyle(LabPalette.teal.opacity(0.75))
                            Text(row.name).font(.system(size: 11, weight: .medium, design: .monospaced))
                            Spacer(minLength: 8)
                            Text("\(row.bytes.formatted()) B")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(LabPalette.muted)
                        }
                        Text(row.sha256)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(LabPalette.muted)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(13)
                    .background(LabPalette.inset)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            }
        }
        .padding(20)
        .labPanel()
    }

    private var scopePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            panelHeading("What this graph proves", subtitle: "Static agreement, not live repository execution")
            Text("JSON and CBOR independently describe the same fixed candidate. Each reconstruction returns to its original carrier, and the join verifies the graph, witnesses and commitments.")
                .font(.system(size: 11.5))
                .foregroundStyle(LabPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
            Text("The role and predicate witnesses describe the live Gate E contract. They are not observations that those roles ran. The authority vector remains 00000000.")
                .font(.system(size: 11.5))
                .foregroundStyle(LabPalette.amber.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .labPanel()
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("STATIC PROOF ≠ LIVE GATE E · In-process algorithms, not process isolation.")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(LabPalette.amber.opacity(0.85))
            Text(model.environmentSummary.isEmpty ? "Normal native application environment. No environment values displayed." : model.environmentSummary)
                .font(.system(size: 9))
                .foregroundStyle(LabPalette.muted)
            Text("Interval retains exact rational clock terms and excludes system sleep. Energy is not inferred from time.")
                .font(.system(size: 9))
                .foregroundStyle(LabPalette.muted)
        }
        .padding(.vertical, 2)
    }

    private func summaryMetric(_ label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label).font(.system(size: 8, weight: .medium)).tracking(0.8).foregroundStyle(LabPalette.muted)
            Text(value).font(.system(size: 11, weight: .medium)).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func commitmentRow(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            eyebrow(label)
            Text(value.isEmpty ? "Awaiting verified output" : value)
                .font(.system(size: 10.5, design: .monospaced))
                .foregroundStyle(value.isEmpty ? LabPalette.muted : LabPalette.teal.opacity(0.9))
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct JoinedGraphPanel: View {
    let graph: DisplayGraph
    @State private var selectedID: String?

    private var selectedNode: DisplayGraph.Node? {
        graph.nodes.first { $0.id == selectedID } ?? graph.relations.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                panelHeading("Joined graph", subtitle: "Drawn from authoritativeGraph bytes")
                Spacer(minLength: 8)
                HStack(spacing: 8) {
                    countTag(graph.facts.count, "facts")
                    countTag(graph.relations.count, graph.relations.count == 1 ? "transition" : "transitions")
                    countTag(graph.edges.count, "edges")
                }
            }
            GraphCanvas(graph: graph, selectedID: $selectedID)
                .frame(height: 330)
                .background(LabPalette.inset)
                .clipShape(RoundedRectangle(cornerRadius: 9))
            HStack(spacing: 19) {
                Label("FACT · state / witness", systemImage: "rectangle")
                    .foregroundStyle(LabPalette.teal)
                Label("RELATION · transition", systemImage: "diamond")
                    .foregroundStyle(LabPalette.amber)
                Spacer()
                Text("Select a node to inspect")
                    .foregroundStyle(LabPalette.muted)
            }
            .font(.system(size: 9))
            if let node = selectedNode {
                VStack(alignment: .leading, spacing: 9) {
                    Text(node.title.uppercased())
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(0.9)
                        .foregroundStyle(node.isRelation ? LabPalette.amber : LabPalette.teal)
                    Text(node.id)
                        .font(.system(size: 9.5, design: .monospaced))
                        .foregroundStyle(LabPalette.muted)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(node.fields) { field in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(field.key).font(.system(size: 9)).foregroundStyle(LabPalette.muted)
                            Text(field.value)
                                .font(.system(size: 10, design: .monospaced))
                                .textSelection(.enabled)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(LabPalette.inset)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            }
        }
        .padding(20)
        .labPanel()
    }

    private func countTag(_ count: Int, _ label: String) -> some View {
        Text("\(count) \(label)")
            .font(.system(size: 9, design: .monospaced))
            .foregroundStyle(LabPalette.muted)
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
            .background(LabPalette.inset)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

private struct GraphCanvas: View {
    let graph: DisplayGraph
    @Binding var selectedID: String?

    var body: some View {
        GeometryReader { geometry in
            let positions = graph.positions(in: geometry.size)
            ZStack {
                Canvas { context, _ in
                    for edge in graph.edges {
                        guard let from = positions[edge.sourceID],
                              let to = positions[edge.targetID]
                        else { continue }
                        let direction: CGFloat = to.x >= from.x ? 1 : -1
                        let start = CGPoint(x: from.x + direction * 74, y: from.y)
                        let end = CGPoint(x: to.x - direction * 77, y: to.y)
                        let middle = (start.x + end.x) / 2
                        var path = Path()
                        path.move(to: start)
                        path.addCurve(to: end,
                                      control1: CGPoint(x: middle, y: start.y),
                                      control2: CGPoint(x: middle, y: end.y))
                        let color = edge.role.contains("WITNESS") ? LabPalette.teal.opacity(0.35) : LabPalette.teal.opacity(0.72)
                        context.stroke(path, with: .color(color), lineWidth: 1)
                        var arrow = Path()
                        arrow.move(to: end)
                        arrow.addLine(to: CGPoint(x: end.x - direction * 6, y: end.y - 3))
                        arrow.addLine(to: CGPoint(x: end.x - direction * 6, y: end.y + 3))
                        arrow.closeSubpath()
                        context.fill(arrow, with: .color(color))
                    }
                }
                .accessibilityHidden(true)
                ForEach(graph.nodes) { node in
                    if let position = positions[node.id] {
                        Button {
                            selectedID = node.id
                        } label: {
                            graphNode(node)
                        }
                        .buttonStyle(.plain)
                        .position(position)
                        .help("\(node.title)\n\(node.id)")
                        .accessibilityLabel("\(node.isRelation ? "Transition" : node.subtype), \(node.title), \(node.id)")
                    }
                }
            }
        }
    }

    private func graphNode(_ node: DisplayGraph.Node) -> some View {
        let color = node.isRelation ? LabPalette.amber : LabPalette.teal
        let selected = selectedID == node.id || (selectedID == nil && node.isRelation)
        return HStack(spacing: 9) {
            Image(systemName: node.isRelation ? "diamond" : (node.subtype == "STATE" ? "circle.inset.filled" : "square.dotted"))
                .font(.system(size: 12))
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 5) {
                Text(node.title).font(.system(size: 10.5, weight: .medium)).lineLimit(1)
                Text(String(node.id.prefix(12)))
                    .font(.system(size: 8.5, design: .monospaced))
                    .foregroundStyle(LabPalette.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 11)
        .frame(width: 150, height: 46)
        .background(selected ? color.opacity(0.075) : LabPalette.panel)
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .overlay(RoundedRectangle(cornerRadius: 7).stroke(color.opacity(selected ? 0.8 : 0.24), lineWidth: selected ? 1.2 : 0.7))
    }
}

// This deliberately small parser is only a view adapter for already-joined bytes.
// It neither recreates the graph nor evaluates a proof predicate.
private struct DisplayGraph {
    struct Field: Identifiable {
        let key: String
        let value: String
        var id: String { key }
    }

    struct Node: Identifiable {
        let id: String
        let subtype: String
        let body: [String: Any]
        let isRelation: Bool

        var title: String {
            if isRelation { return "Schema transition" }
            let raw = body["state_class"] as? String ?? body["kind"] as? String ?? subtype
            return raw.lowercased().replacingOccurrences(of: "_", with: " ").capitalized
        }

        var fields: [Field] {
            body.keys.sorted().map { key in
                let value: String
                if let string = body[key] as? String {
                    value = string
                } else if let strings = body[key] as? [String] {
                    value = strings.joined(separator: "\n")
                } else if body[key] is NSNull {
                    value = "null"
                } else {
                    value = String(describing: body[key] ?? "")
                }
                return Field(key: key, value: value)
            }
        }
    }

    struct Edge {
        let sourceID: String
        let targetID: String
        let role: String
    }

    enum DecodeFailure: Error { case shape }
    let facts: [Node]
    let relations: [Node]
    let edges: [Edge]
    var nodes: [Node] { facts + relations }

    init(data: Data) throws {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rawFacts = root["facts"] as? [[String: Any]],
              let rawRelations = root["relations"] as? [[String: Any]],
              let rawEdges = root["edges"] as? [[String: Any]]
        else { throw DecodeFailure.shape }
        func node(_ row: [String: Any], isRelation: Bool) throws -> Node {
            guard let id = row["id"] as? String,
                  let subtype = row["subtype"] as? String,
                  let body = row["body"] as? [String: Any]
            else { throw DecodeFailure.shape }
            return Node(id: id, subtype: subtype, body: body, isRelation: isRelation)
        }
        facts = try rawFacts.map { try node($0, isRelation: false) }
        relations = try rawRelations.map { try node($0, isRelation: true) }
        edges = try rawEdges.map { row in
            guard let source = row["source_id"] as? String,
                  let target = row["target_id"] as? String,
                  let role = row["role"] as? String
            else { throw DecodeFailure.shape }
            return Edge(sourceID: source, targetID: target, role: role)
        }
        let identifiers = Set((facts + relations).map(\.id))
        guard identifiers.count == facts.count + relations.count,
              edges.allSatisfy({ identifiers.contains($0.sourceID) && identifiers.contains($0.targetID) })
        else { throw DecodeFailure.shape }
    }

    func positions(in size: CGSize) -> [String: CGPoint] {
        let order = ["STATIC_INPUT", "SOURCE_BINDING", "ROLE_ORDER", "PREDICATE_SET", "AUTHORITY_PRESTATE"]
        let right = facts.filter { $0.body["state_class"] as? String == "STATIC_READY" }
        let left = facts.filter { $0.body["state_class"] as? String != "STATIC_READY" }.sorted { first, second in
            func rank(_ node: Node) -> Int {
                let key = node.body["state_class"] as? String ?? node.body["kind"] as? String ?? ""
                return order.firstIndex(of: key) ?? order.count
            }
            return rank(first) == rank(second) ? first.id < second.id : rank(first) < rank(second)
        }
        var result: [String: CGPoint] = [:]
        for (index, node) in left.enumerated() {
            let fraction = left.count > 1 ? CGFloat(index) / CGFloat(left.count - 1) : 0.5
            result[node.id] = CGPoint(x: 88, y: 33 + fraction * max(0, size.height - 66))
        }
        for (index, node) in relations.enumerated() {
            result[node.id] = CGPoint(x: size.width * 0.54, y: size.height * CGFloat(index + 1) / CGFloat(relations.count + 1))
        }
        for (index, node) in right.enumerated() {
            result[node.id] = CGPoint(x: size.width - 88, y: size.height * CGFloat(index + 1) / CGFloat(right.count + 1))
        }
        return result
    }
}

private func eyebrow(_ text: String) -> some View {
    Text(text)
        .font(.system(size: 8.5, weight: .semibold))
        .tracking(1.2)
        .foregroundStyle(LabPalette.muted)
}

private func statusPill(_ text: String, color: Color) -> some View {
    HStack(spacing: 6) {
        Circle().fill(color).frame(width: 4, height: 4)
        Text(text).font(.system(size: 8.5, weight: .semibold, design: .monospaced)).tracking(0.4)
    }
    .foregroundStyle(color)
    .padding(.horizontal, 10)
    .padding(.vertical, 7)
    .background(color.opacity(0.085))
    .clipShape(Capsule())
    .overlay(Capsule().stroke(color.opacity(0.16), lineWidth: 0.7))
}

private func panelHeading(_ title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 5) {
        Text(title).font(.system(size: 13, weight: .semibold))
        Text(subtitle).font(.system(size: 10)).foregroundStyle(LabPalette.muted)
    }
}

private extension View {
    func labPanel() -> some View {
        background(LabPalette.panel)
            .clipShape(RoundedRectangle(cornerRadius: 11))
            .overlay(RoundedRectangle(cornerRadius: 11).stroke(LabPalette.line, lineWidth: 1))
    }
}
