import LedgerProjectionCore
import SwiftUI

struct ProjectionTimelineView: View {
    let entries: [LedgerTimelineEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProjectionSectionHeader(
                title: "Source-ordered timeline",
                explanation:
                    "Order is the projection's exact record order. It is not a "
                    + "latest-truth rule or an authority transition.",
                count: entries.count
            )
            if entries.isEmpty {
                ContentUnavailableView(
                    "No timeline rows",
                    systemImage: "list.bullet.rectangle",
                    description: Text("The admitted projection contains no timeline entries.")
                )
            } else {
                Table(entries) {
                    TableColumn("Ordinal") { entry in
                        Text(String(entry.recordOrdinal)).monospacedDigit()
                    }
                    .width(min: 60, ideal: 70)
                    TableColumn("Line") { entry in
                        Text(String(entry.lineNumber)).monospacedDigit()
                    }
                    .width(min: 55, ideal: 70)
                    TableColumn("Section") { entry in
                        ExactCell(entry.sectionTitle)
                    }
                    .width(min: 120, ideal: 220)
                    TableColumn("Schema") { entry in
                        ExactCell(entry.schema)
                    }
                    .width(min: 140, ideal: 240)
                    TableColumn("Status") { entry in
                        ExactCell(entry.status)
                    }
                    .width(min: 130, ideal: 230)
                    TableColumn("Canonical state") { entry in
                        ExactCell(entry.canonicalState)
                    }
                    .width(min: 130, ideal: 190)
                    TableColumn("Payload hash state") { entry in
                        ExactCell(entry.payloadHashState)
                    }
                    .width(min: 130, ideal: 190)
                    TableColumn("Payload SHA-256") { entry in
                        ExactCell(entry.payloadSHA256)
                    }
                    .width(min: 220, ideal: 430)
                    TableColumn("Frame SHA-256") { entry in
                        ExactCell(entry.frameSHA256)
                    }
                    .width(min: 220, ideal: 430)
                }
            }
        }
        .padding(20)
        .navigationTitle("Timeline")
    }
}

struct ProjectionRecordsView: View {
    let records: [LedgerRawRecord]
    @State private var selectedOrdinal: Int?

    private var selectedRecord: LedgerRawRecord? {
        guard let selectedOrdinal else { return records.first }
        return records.first { $0.recordOrdinal == selectedOrdinal }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProjectionSectionHeader(
                title: "Raw JSON records",
                explanation:
                    "Bytes and canonical-state classification are displayed "
                    + "verbatim from each projection record. Prose and source "
                    + "ordering do not override these fields.",
                count: records.count
            )
            if records.isEmpty {
                ContentUnavailableView(
                    "No raw records",
                    systemImage: "doc.plaintext",
                    description: Text("The admitted projection contains no raw JSON records.")
                )
            } else {
                HSplitView {
                    List(selection: $selectedOrdinal) {
                        ForEach(records) { record in
                            RecordListRow(record: record)
                                .tag(record.recordOrdinal)
                        }
                    }
                    .frame(minWidth: 280, idealWidth: 340)

                    if let record = selectedRecord {
                        RawRecordDetail(record: record)
                            .frame(minWidth: 520)
                    }
                }
            }
        }
        .padding(20)
        .navigationTitle("Raw records")
        .onAppear {
            if selectedOrdinal == nil {
                selectedOrdinal = records.first?.recordOrdinal
            }
        }
    }
}

private struct RecordListRow: View {
    let record: LedgerRawRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("#\(record.recordOrdinal)")
                    .font(.caption.weight(.semibold).monospacedDigit())
                Text("line \(record.lineNumber)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Text(record.status ?? "status absent")
                .font(.callout.monospaced())
                .lineLimit(2)
            Text(record.schema ?? "schema absent")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 3)
    }
}

private struct RawRecordDetail: View {
    let record: LedgerRawRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 7) {
                RecordMetadataRow(label: "Ordinal", value: String(record.recordOrdinal))
                RecordMetadataRow(label: "Line", value: String(record.lineNumber))
                RecordMetadataRow(label: "Schema", value: record.schema ?? "ABSENT")
                RecordMetadataRow(label: "Status", value: record.status ?? "ABSENT")
                RecordMetadataRow(label: "Canonical", value: record.canonicalState)
                RecordMetadataRow(label: "Frame SHA-256", value: record.frameSHA256)
            }
            Divider()
            Text("RAW JSON")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            ScrollView([.horizontal, .vertical]) {
                Text(record.rawJSON)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(.leading, 14)
    }
}

private struct RecordMetadataRow: View {
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

private struct ExactCell: View {
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

struct ProjectionSectionHeader: View {
    let title: String
    let explanation: String
    let count: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.weight(.semibold))
                Text(explanation)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(count) rows")
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}
