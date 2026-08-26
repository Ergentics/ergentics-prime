import LedgerProjectionCore
import SwiftUI

enum InterfaceDestination: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case timeline = "Timeline"
    case records = "Raw records"
    case states = "State tokens"
    case graph = "Graph"
    case energy = "Energy"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .overview: "rectangle.grid.2x2"
        case .timeline: "list.bullet.rectangle"
        case .records: "doc.plaintext"
        case .states: "tag"
        case .graph: "point.3.connected.trianglepath.dotted"
        case .energy: "bolt"
        }
    }
}

struct InterfaceShell: View {
    let availability: LedgerProjectionAvailability

    var body: some View {
        VStack(spacing: 0) {
            NonAuthorityBanner(metadata: admittedSnapshot?.metadata)
            Divider()
            content
        }
        .frame(minWidth: 980, minHeight: 680)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder
    private var content: some View {
        switch availability {
        case .empty:
            ProjectionUnavailableView(
                title: "No projection loaded",
                symbol: "tray",
                explanation:
                    "The required projection environment is absent. "
                    + "No ledger state has been inferred. Configure the exact "
                    + "SQLite projection admission and relaunch this application."
            )
        case .rejected(let rejection):
            ProjectionRejectedView(rejection: rejection)
        case .admitted(let snapshot):
            AdmittedProjectionView(snapshot: snapshot)
        }
    }

    private var admittedSnapshot: LedgerProjectionSnapshot? {
        guard case .admitted(let snapshot) = availability else { return nil }
        return snapshot
    }
}

private struct NonAuthorityBanner: View {
    let metadata: LedgerProjectionMetadata?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "eye.trianglebadge.exclamationmark")
                .font(.title3.weight(.semibold))
            VStack(alignment: .leading, spacing: 2) {
                Text("NON-AUTHORITATIVE / 00000000")
                    .font(.headline.monospaced())
                Text("Read-only presentation. It cannot feed a controller or close an authority.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let metadata {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Projection admitted")
                        .font(.subheadline.weight(.semibold))
                    Text(metadata.projectionID)
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .textSelection(.enabled)
                }
            } else {
                Text("No admitted input")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.orange.opacity(0.12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Non-authoritative projection, authority vector zero zero zero zero zero zero zero zero")
    }
}

private struct ProjectionUnavailableView: View {
    let title: String
    let symbol: String
    let explanation: String

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: symbol)
        } description: {
            Text(explanation)
                .frame(maxWidth: 560)
        }
        .accessibilityIdentifier("projection-empty-state")
    }
}

private struct ProjectionRejectedView: View {
    let rejection: LedgerProjectionRejection

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "xmark.shield")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(.red)
            Text("Projection rejected")
                .font(.title2.weight(.semibold))
            VStack(alignment: .leading, spacing: 10) {
                ProjectionField(label: "Code", value: rejection.code)
                ProjectionField(label: "Detail", value: rejection.detail)
            }
            .padding(16)
            .frame(maxWidth: 680, alignment: .leading)
            .background(.red.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
            Text("No rows from this input are displayed or interpreted.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(28)
        .accessibilityIdentifier("projection-rejected-state")
    }
}

private struct AdmittedProjectionView: View {
    let snapshot: LedgerProjectionSnapshot
    @State private var destination: InterfaceDestination? = .overview

    var body: some View {
        NavigationSplitView {
            List(InterfaceDestination.allCases, selection: $destination) { item in
                Label(item.rawValue, systemImage: item.systemImage)
                    .tag(item)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 210, max: 260)
            .accessibilityIdentifier("projection-navigation")
        } detail: {
            detail
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch destination ?? .overview {
        case .overview:
            ProjectionOverviewView(snapshot: snapshot)
        case .timeline:
            ProjectionTimelineView(entries: snapshot.timeline)
        case .records:
            ProjectionRecordsView(records: snapshot.records)
        case .states:
            ProjectionStateTokensView(tokens: snapshot.stateTokens)
        case .graph:
            ProjectionGraphView(
                nodes: snapshot.graphNodes,
                edges: snapshot.graphEdges
            )
        case .energy:
            ProjectionEnergyView(facts: snapshot.energyFacts)
        }
    }
}

struct ProjectionField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.callout.monospaced())
                .textSelection(.enabled)
        }
    }
}
