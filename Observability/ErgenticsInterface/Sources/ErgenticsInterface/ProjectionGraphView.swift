import LedgerProjectionCore
import SwiftUI

struct ProjectionGraphView: View {
    enum TableMode: String, CaseIterable, Identifiable {
        case nodes = "Nodes"
        case edges = "Edges"

        var id: String { rawValue }
    }

    let nodes: [LedgerGraphNode]
    let edges: [LedgerGraphEdge]
    @State private var tableMode = TableMode.nodes

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProjectionSectionHeader(
                title: "Digest-joined graph",
                explanation:
                    "The canvas is a deterministic compact preview. The tables "
                    + "retain every exact node and edge supplied by the projection.",
                count: nodes.count + edges.count
            )
            ProjectionGraphCanvas(nodes: nodes, edges: edges)
                .frame(height: 250)
                .accessibilityIdentifier("projection-graph-canvas")
            HStack {
                Picker("Graph table", selection: $tableMode) {
                    ForEach(TableMode.allCases) { mode in
                        Text("\(mode.rawValue) (\(count(for: mode)))")
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 360)
                Spacer()
                Text("Exact projection rows")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            switch tableMode {
            case .nodes:
                GraphNodesTable(nodes: nodes)
            case .edges:
                GraphEdgesTable(edges: edges)
            }
        }
        .padding(20)
        .navigationTitle("Graph")
    }

    private func count(for mode: TableMode) -> Int {
        switch mode {
        case .nodes: nodes.count
        case .edges: edges.count
        }
    }
}

private struct ProjectionGraphCanvas: View {
    let nodes: [LedgerGraphNode]
    let edges: [LedgerGraphEdge]

    private let nodeLimit = 48
    private let edgeLimit = 96

    private var previewNodes: [LedgerGraphNode] {
        Array(nodes.prefix(nodeLimit))
    }

    private var previewEdges: [LedgerGraphEdge] {
        let admittedIDs = Set(previewNodes.map(\.nodeID))
        return Array(
            edges.lazy.filter {
                admittedIDs.contains($0.fromNodeID)
                    && admittedIDs.contains($0.toNodeID)
            }.prefix(edgeLimit)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("Compact preview")
                    .font(.headline)
                Spacer()
                Text(
                    "first \(previewNodes.count)/\(nodes.count) nodes · "
                    + "\(previewEdges.count)/\(edges.count) joined edges"
                )
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            }
            if previewNodes.isEmpty {
                ContentUnavailableView(
                    "No graph rows",
                    systemImage: "point.3.connected.trianglepath.dotted"
                )
            } else {
                Canvas { context, size in
                    let positions = nodePositions(in: size)
                    for edge in previewEdges {
                        guard let start = positions[edge.fromNodeID],
                              let end = positions[edge.toNodeID] else { continue }
                        var path = Path()
                        path.move(to: start)
                        path.addLine(to: end)
                        context.stroke(
                            path,
                            with: .color(.secondary.opacity(0.3)),
                            lineWidth: edge.evidenceGrade.lowercased().contains("exact")
                                ? 1.4 : 0.8
                        )
                    }
                    for node in previewNodes {
                        guard let point = positions[node.nodeID] else { continue }
                        let radius: CGFloat = 5
                        let marker = Path(
                            ellipseIn: CGRect(
                                x: point.x - radius,
                                y: point.y - radius,
                                width: radius * 2,
                                height: radius * 2
                            )
                        )
                        context.fill(marker, with: .color(color(for: node.kind)))
                    }
                }
                .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(nsColor: .separatorColor).opacity(0.65), lineWidth: 1)
                }
            }
        }
    }

    private func nodePositions(in size: CGSize) -> [String: CGPoint] {
        let columns = 8
        let rows = max(1, (previewNodes.count + columns - 1) / columns)
        let horizontalInset: CGFloat = 18
        let verticalInset: CGFloat = 18
        let usableWidth = max(1, size.width - horizontalInset * 2)
        let usableHeight = max(1, size.height - verticalInset * 2)
        var positions: [String: CGPoint] = [:]
        for (index, node) in previewNodes.enumerated() {
            let column = index % columns
            let row = index / columns
            let xFraction = CGFloat(column) / CGFloat(columns - 1)
            let yFraction = rows == 1 ? 0.5 : CGFloat(row) / CGFloat(rows - 1)
            positions[node.nodeID] = CGPoint(
                x: horizontalInset + usableWidth * xFraction,
                y: verticalInset + usableHeight * yFraction
            )
        }
        return positions
    }

    private func color(for kind: String) -> Color {
        let normalized = kind.lowercased()
        if normalized.contains("record") { return .blue }
        if normalized.contains("digest") { return .purple }
        if normalized.contains("state") { return .orange }
        if normalized.contains("section") { return .green }
        return .secondary
    }
}

private struct GraphNodesTable: View {
    let nodes: [LedgerGraphNode]

    var body: some View {
        if nodes.isEmpty {
            ContentUnavailableView("No graph nodes", systemImage: "circle.dotted")
        } else {
            Table(nodes) {
                TableColumn("Node ID") { node in GraphCell(node.nodeID) }
                    .width(min: 180, ideal: 330)
                TableColumn("Kind") { node in GraphCell(node.kind) }
                    .width(min: 100, ideal: 160)
                TableColumn("Canonical key") { node in GraphCell(node.canonicalKey) }
                    .width(min: 180, ideal: 330)
                TableColumn("Label") { node in GraphCell(node.label) }
                    .width(min: 150, ideal: 300)
                TableColumn("Record") { node in
                    GraphCell(node.recordOrdinal.map(String.init) ?? "ABSENT")
                }
                .width(min: 65, ideal: 80)
                TableColumn("JSON pointer") { node in
                    GraphCell(node.jsonPointer ?? "ABSENT")
                }
                .width(min: 180, ideal: 340)
            }
        }
    }
}

private struct GraphEdgesTable: View {
    let edges: [LedgerGraphEdge]

    var body: some View {
        if edges.isEmpty {
            ContentUnavailableView("No graph edges", systemImage: "arrow.left.and.right")
        } else {
            Table(edges) {
                TableColumn("Edge ID") { edge in GraphCell(edge.edgeID) }
                    .width(min: 180, ideal: 320)
                TableColumn("From") { edge in GraphCell(edge.fromNodeID) }
                    .width(min: 160, ideal: 280)
                TableColumn("Predicate") { edge in GraphCell(edge.predicate) }
                    .width(min: 120, ideal: 220)
                TableColumn("To") { edge in GraphCell(edge.toNodeID) }
                    .width(min: 160, ideal: 280)
                TableColumn("Record") { edge in
                    GraphCell(edge.sourceRecordOrdinal.map(String.init) ?? "ABSENT")
                }
                .width(min: 65, ideal: 80)
                TableColumn("Source pointer") { edge in
                    GraphCell(edge.sourceJSONPointer ?? "ABSENT")
                }
                .width(min: 180, ideal: 340)
                TableColumn("Evidence grade") { edge in GraphCell(edge.evidenceGrade) }
                    .width(min: 150, ideal: 260)
            }
        }
    }
}

private struct GraphCell: View {
    let value: String

    init(_ value: String) {
        self.value = value
    }

    var body: some View {
        Text(value)
            .font(.caption.monospaced())
            .textSelection(.enabled)
            .lineLimit(2)
            .help(value)
    }
}
