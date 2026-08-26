import LedgerProjectionCore
import SwiftUI

struct ProjectionStateTokensView: View {
    let tokens: [LedgerStateToken]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProjectionSectionHeader(
                title: "Exact state tokens",
                explanation:
                    "Tokens are projection-provided lexical facts. The viewer "
                    + "does not promote them or select a winning state.",
                count: tokens.count
            )
            if tokens.isEmpty {
                ContentUnavailableView(
                    "No state tokens",
                    systemImage: "tag",
                    description: Text("The admitted projection contains no state-token rows.")
                )
            } else {
                Table(tokens) {
                    TableColumn("Record") { token in
                        Text(String(token.recordOrdinal)).monospacedDigit()
                    }
                    .width(min: 60, ideal: 75)
                    TableColumn("JSON pointer") { token in
                        StateCell(token.jsonPointer)
                    }
                    .width(min: 220, ideal: 420)
                    TableColumn("Exact value") { token in
                        StateCell(token.exactValue)
                    }
                    .width(min: 160, ideal: 320)
                    TableColumn("Class") { token in
                        StateCell(token.stateClass)
                    }
                    .width(min: 120, ideal: 220)
                    TableColumn("Canonical source") { token in
                        Text(String(token.canonicalSource))
                            .font(.caption.monospaced())
                    }
                    .width(min: 105, ideal: 125)
                }
            }
        }
        .padding(20)
        .navigationTitle("State tokens")
    }
}

struct ProjectionEnergyView: View {
    let facts: [LedgerEnergyFact]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProjectionSectionHeader(
                title: "Energy facts with qualification",
                explanation:
                    "Each exact value is displayed with the exact sibling unit "
                    + "and qualification states, including ABSENT, plus "
                    + "the reader's digest-pinned selection grade. No inference occurs here.",
                count: facts.count
            )
            qualificationBanner
            if facts.isEmpty {
                ContentUnavailableView(
                    "No energy facts",
                    systemImage: "bolt.slash",
                    description: Text(
                        "The admitted projection contains no qualified energy rows."
                    )
                )
            } else {
                Table(facts) {
                    TableColumn("Record") { fact in
                        Text(String(fact.recordOrdinal)).monospacedDigit()
                    }
                    .width(min: 60, ideal: 75)
                    TableColumn("JSON pointer") { fact in
                        StateCell(fact.jsonPointer)
                    }
                    .width(min: 220, ideal: 420)
                    TableColumn("Exact value") { fact in
                        StateCell(fact.exactValue)
                    }
                    .width(min: 130, ideal: 220)
                    TableColumn("Unit") { fact in
                        OptionalStateCell(fact.unit)
                    }
                    .width(min: 80, ideal: 120)
                    TableColumn("Qualification") { fact in
                        OptionalStateCell(fact.qualification)
                    }
                    .width(min: 180, ideal: 340)
                    TableColumn("Evidence grade") { fact in
                        StateCell(fact.evidenceGrade)
                    }
                    .width(min: 180, ideal: 360)
                }
            }
        }
        .padding(20)
        .navigationTitle("Energy")
    }

    private var qualificationBanner: some View {
        Label {
            Text(
                "Energy is shown as recorded data with its qualification—not "
                + "as wall-plug, package, GPU, ANE, or scientific authority."
            )
            .font(.callout)
        } icon: {
            Image(systemName: "info.circle.fill")
        }
        .foregroundStyle(.secondary)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 9))
    }
}

private struct StateCell: View {
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

private struct OptionalStateCell: View {
    let value: String?

    init(_ value: String?) {
        self.value = value
    }

    var body: some View {
        Text(value ?? "ABSENT")
            .font(.caption.monospaced())
            .textSelection(.enabled)
            .lineLimit(2)
            .help(value ?? "ABSENT")
    }
}
