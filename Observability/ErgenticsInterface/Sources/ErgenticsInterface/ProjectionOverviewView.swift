import LedgerProjectionCore
import SwiftUI

struct ProjectionOverviewView: View {
    let snapshot: LedgerProjectionSnapshot

    private var countItems: [(String, Int)] {
        let counts = snapshot.counts
        return [
            ("Sections", counts.sections),
            ("Fences", counts.fences),
            ("Records", counts.records),
            ("Canonical records", counts.canonicalRecords),
            ("Legacy records", counts.legacyRecords),
            ("JSON nodes", counts.jsonNodes),
            ("State tokens", counts.stateTokens),
            ("Digest occurrences", counts.digestOccurrences),
            ("Graph nodes", counts.graphNodes),
            ("Graph edges", counts.graphEdges),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heading
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 150), spacing: 12),
                    ],
                    spacing: 12
                ) {
                    ForEach(countItems, id: \.0) { item in
                        CountCard(label: item.0, value: item.1)
                    }
                }
                metadata
                boundary
            }
            .padding(24)
        }
        .navigationTitle("Projection overview")
        .accessibilityIdentifier("projection-admitted-state")
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Admitted presentation snapshot")
                .font(.title2.weight(.semibold))
            Text(
                "Counts and identifiers below are copied from the admitted "
                + "projection. They do not supersede the canonical ledger."
            )
            .foregroundStyle(.secondary)
        }
    }

    private var metadata: some View {
        GroupBox("Exact identity") {
            Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 12) {
                MetadataRow(label: "Projection", value: snapshot.metadata.projectionID)
                MetadataRow(label: "Source commit", value: snapshot.metadata.sourceCommit)
                MetadataRow(label: "Source tree", value: snapshot.metadata.sourceTree)
                MetadataRow(label: "Source blob", value: snapshot.metadata.sourceBlob)
                MetadataRow(label: "Source SHA-256", value: snapshot.metadata.sourceSHA256)
                MetadataRow(label: "Database SHA-256", value: snapshot.metadata.databaseSHA256)
                MetadataRow(
                    label: "Database bytes",
                    value: String(snapshot.metadata.databaseBytes)
                )
                MetadataRow(
                    label: "Relational export SHA-256",
                    value: snapshot.metadata.relationalExportSHA256
                )
                MetadataRow(
                    label: "Graph export SHA-256",
                    value: snapshot.metadata.graphExportSHA256
                )
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var boundary: some View {
        GroupBox("Authority boundary") {
            Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 12) {
                MetadataRow(
                    label: "Authority vector",
                    value: snapshot.metadata.authorityVector
                )
                MetadataRow(
                    label: "Authoritative",
                    value: String(snapshot.metadata.authoritative)
                )
                MetadataRow(
                    label: "May feed controller",
                    value: String(snapshot.metadata.mayFeedController)
                )
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct CountCard: View {
    let label: String
    let value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(String(value))
                .font(.title2.weight(.semibold).monospacedDigit())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        GridRow {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .gridColumnAlignment(.trailing)
            Text(value)
                .font(.caption.monospaced())
                .textSelection(.enabled)
                .gridColumnAlignment(.leading)
        }
    }
}
