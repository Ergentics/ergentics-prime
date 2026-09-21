import SwiftUI

/// Presentation-only workspace surface. The view receives no model, URL, raw
/// observation, lease, token, or filesystem capability.
@MainActor
struct PrimeGitView: View {
    let presentation: ManagedWorkspaceProductGUIPresentation
    let importState: ManagedWorkspaceGUIImportState
    let admitted: Bool
    let onProposal: (ManagedWorkspaceGUIProposal) -> Void

    @State private var pane: Pane = .overview

    private enum Pane: String, CaseIterable, Identifiable {
        case overview = "Overview"
        case changes = "Changes"
        case privacy = "Privacy"
        var id: String { rawValue }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
            Divider()
            capabilityStrip
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if !admitted {
                        notice(
                            "Application identity is not admitted. Snapshot import is unavailable.",
                            symbol: "lock.trianglebadge.exclamationmark",
                            tone: .orange
                        )
                    }
                    if let rejection = rejectionMessage {
                        notice(rejection, symbol: "exclamationmark.triangle", tone: .orange)
                    }

                    scopeCard
                    plannedActions

                    switch presentation.observation {
                    case .notImported:
                        emptyState
                    case .imported(let imported):
                        importedContent(imported)
                    }
                }
                .padding(24)
                .frame(maxWidth: 1120, alignment: .leading)
            }
            Divider()
            footer
                .padding(.horizontal, 24)
                .padding(.vertical, 11)
        }
        .background(.background)
        .tint(.teal)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(.teal)
                .frame(width: 44, height: 44)
                .background(.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 9) {
                    Text(presentation.workspaceDisplayName)
                        .font(.title2.weight(.semibold))
                    Label("Minimized view", systemImage: "eye.slash")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                Text("Imported producer claims · no live repository access")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 16)
            activityBadge
            switch presentation.activity {
            case .assessing:
                Button {
                    onProposal(.cancelAssessment)
                } label: {
                    Label("Cancel assessment", systemImage: "stop.circle")
                }
                .buttonStyle(.bordered)
                .help("Request cancellation; postflight and resource release will still finish.")
                .accessibilityIdentifier("prime-git-cancel-assessment")
            case .cancellationRequested:
                Button("Cancellation requested") {}
                    .buttonStyle(.bordered)
                    .disabled(true)
            case .settling:
                EmptyView()
            case .idle, .unavailable:
                Button {
                    onProposal(.requestSnapshotImport)
                } label: {
                    Label("Import snapshot…", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!admitted || presentation.activity != .idle)
                .help("Read one user-selected JSON snapshot and retain only its minimized presentation.")
                .accessibilityIdentifier("prime-git-import-snapshot")
            }
        }
    }

    private var capabilityStrip: some View {
        ViewThatFits {
            HStack(spacing: 10) {
                boundaryChip("Local file", symbol: "doc")
                boundaryChip("No live Git", symbol: "arrow.triangle.branch")
                boundaryChip("No network", symbol: "network.slash")
                boundaryChip("No write authority", symbol: "lock")
                Spacer(minLength: 0)
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    boundaryChip("Local file", symbol: "doc")
                    boundaryChip("No live Git", symbol: "arrow.triangle.branch")
                }
                HStack {
                    boundaryChip("No network", symbol: "network.slash")
                    boundaryChip("No write authority", symbol: "lock")
                }
            }
        }
        .font(.caption.weight(.medium))
    }

    private func boundaryChip(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.quaternary, in: Capsule())
            .accessibilityLabel(title)
    }

    private var activityBadge: some View {
        let value: (String, String) = switch presentation.activity {
        case .idle: ("Idle", "circle")
        case .assessing: ("Assessment active", "hourglass")
        case .cancellationRequested: ("Cancellation requested", "stop.circle")
        case .settling: ("Settling postflight", "checkmark.arrow.trianglehead.counterclockwise")
        case .unavailable: ("Assessment unavailable", "lock.trianglebadge.exclamationmark")
        }
        return Label(value.0, systemImage: value.1)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .accessibilityLabel("Workspace activity: \(value.0)")
    }

    // Keep the visible title and content as ordinary accessible children. A
    // titled GroupBox triggers a tree-transformation failure in the UI reader.
    private func sectionCard<Content: View, Title: View>(
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> Title
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            label()
            content()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }

    private var scopeCard: some View {
        sectionCard {
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) {
                scopeRow("Source", value: sourceScope, symbol: "doc.text")
                scopeRow("Viewer operation", value: "Parse structure and minimize fields", symbol: "rectangle.compress.vertical")
                scopeRow("Live repository", value: "Unknown · not queried", symbol: "questionmark.folder")
                scopeRow("Authority", value: "None · no Gate-E or candidate promotion", symbol: "nosign")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Observation boundary", systemImage: "shield.lefthalf.filled")
                .font(.headline)
        }
    }

    private func scopeRow(_ label: String, value: String, symbol: String) -> some View {
        GridRow {
            Label(label, systemImage: symbol)
                .foregroundStyle(.secondary)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.callout)
        .accessibilityElement(children: .combine)
    }

    private var sourceScope: String {
        switch presentation.observation {
        case .notImported: "No imported snapshot"
        case .imported: "Imported snapshot bytes · raw labels discarded"
        }
    }

    private var plannedActions: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 11) {
                Text("These controls communicate the product roadmap. They have no action closure, keyboard command, process, or network backend in this slice.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                ViewThatFits {
                    HStack(spacing: 8) { unavailableActionLabels }
                    VStack(alignment: .leading, spacing: 8) { unavailableActionLabels }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Planned Git controls — unavailable", systemImage: "hammer")
                .font(.headline)
        }
    }

    @ViewBuilder
    private var unavailableActionLabels: some View {
        unavailableAction("Stage", symbol: "plus.rectangle.on.folder")
        unavailableAction("Unstage", symbol: "minus.rectangle")
        unavailableAction("Commit", symbol: "checkmark.circle")
        unavailableAction("Fetch", symbol: "arrow.down.circle")
        unavailableAction("Pull", symbol: "arrow.down.to.line")
        unavailableAction("Push", symbol: "arrow.up.to.line")
        unavailableAction("Merge", symbol: "arrow.triangle.merge")
    }

    private func unavailableAction(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .font(.caption)
            .foregroundStyle(.tertiary)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(.quaternary.opacity(0.55), in: RoundedRectangle(cornerRadius: 7))
            .accessibilityLabel("\(title), unavailable")
            .accessibilityHint("No Git mutation or network capability is connected.")
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No minimized presentation", systemImage: "doc.text.magnifyingglass")
        } description: {
            Text("Import a recorded local snapshot. Paths, references, object IDs, remote details, timestamps, and source-byte identifiers will not enter the interface.")
        } actions: {
            Button("Import snapshot…") {
                onProposal(.requestSnapshotImport)
            }
            .disabled(!admitted || presentation.activity != .idle)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
    }

    @ViewBuilder
    private func importedContent(_ imported: ManagedWorkspaceProductGUIPresentation.Imported) -> some View {
        HStack {
            Picker("Workspace inspector", selection: $pane) {
                ForEach(Pane.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 420)
            Spacer()
            Button("Clear presentation") {
                onProposal(.clearPresentation)
            }
            .disabled(isImporting)
            .help("Clear only the minimized in-memory presentation.")
        }

        switch pane {
        case .overview:
            overview(imported)
        case .changes:
            changes(imported.changes)
        case .privacy:
            privacyPanel
        }
    }

    private func overview(_ imported: ManagedWorkspaceProductGUIPresentation.Imported) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Label(headLabel(imported.head), systemImage: "arrow.triangle.branch")
                        .font(.title3.weight(.semibold))
                    Text("The branch or reference name is intentionally withheld.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                claimBadge(imported.claim)
            }
            Divider()
            LabeledContent("Remote metadata") {
                Text(remoteLabel(imported.remotes))
            }
            LabeledContent("Cached comparison") {
                Text(comparisonLabel(imported.cachedComparison))
                    .monospacedDigit()
            }
            Text("All values above are imported producer claims. Parsing validates shape; it does not verify a live checkout.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .contain)
    }

    private func changes(_ values: ManagedWorkspaceProductGUIPresentation.ReportedChangeCounts?) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            ViewThatFits {
                HStack(spacing: 12) {
                    countCard("Staged", value: values?.staged, symbol: "checkmark.circle")
                    countCard("Unstaged", value: values?.unstaged, symbol: "pencil.circle")
                    countCard("Untracked", value: values?.untracked, symbol: "questionmark.circle")
                }
                VStack(spacing: 12) {
                    countCard("Staged", value: values?.staged, symbol: "checkmark.circle")
                    countCard("Unstaged", value: values?.unstaged, symbol: "pencil.circle")
                    countCard("Untracked", value: values?.untracked, symbol: "questionmark.circle")
                }
            }
            Label("Unknown means not recorded; it never means zero or clean.", systemImage: "info.circle")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("Counts are imported aggregates. Per-file names, paths, and diffs are not present in this projection.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func countCard(_ title: String, value: UInt32?, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: symbol)
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(value.map(String.init) ?? "Unknown")
                .font(value == nil ? .title3 : .largeTitle.weight(.medium))
                .monospacedDigit()
            Text(value == nil ? "Not recorded" : "Producer-reported count")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityValue(value.map { "Producer reported \($0)" } ?? "Not recorded")
    }

    private var privacyPanel: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 13) {
                Text("The following categories are structurally absent from both the visible interface and its Accessibility values:")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                privacyRow("Filesystem labels", detail: "checkout path and imported filename")
                privacyRow("Repository references", detail: "branch and upstream names")
                privacyRow("Object identifiers", detail: "HEAD and upstream commit IDs")
                privacyRow("Remote metadata", detail: "remote names and locations")
                privacyRow("Time metadata", detail: "recorded observation timestamp")
                privacyRow("Source lineage", detail: "schema, parser, byte count, and digest")
                Divider()
                Label("AI / candidate projection: unavailable", systemImage: "lock")
                    .font(.headline)
                Text("No recipient-, purpose-, epoch-, and field-bound disclosure capability exists yet, so this GUI value is not reused as an AI data channel.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Privacy boundary", systemImage: "hand.raised")
                .font(.headline)
        }
    }

    private func privacyRow(_ title: String, detail: String) -> some View {
        LabeledContent {
            Text(detail).foregroundStyle(.secondary)
        } label: {
            Label(title, systemImage: "eye.slash")
        }
        .font(.callout)
        .accessibilityElement(children: .combine)
    }

    private func claimBadge(_ claim: ManagedWorkspaceProductGUIPresentation.Claim) -> some View {
        let value: (String, String, Color) = switch claim {
        case .unchecked:
            ("Producer did not check consistency", "questionmark.circle", .secondary)
        case .producerReportedStable:
            ("Producer reported stable capture", "info.circle", .secondary)
        case .producerReportedChanged:
            ("Producer reported changed capture", "exclamationmark.triangle", .orange)
        }
        return Label(value.0, systemImage: value.1)
            .font(.caption.weight(.medium))
            .foregroundStyle(value.2)
            .accessibilityLabel(value.0)
            .help("This is an imported producer claim, not live or independently verified state.")
    }

    private func headLabel(_ head: ManagedWorkspaceProductGUIPresentation.ReportedHeadMode) -> String {
        switch head {
        case .branch: "Producer reported branch HEAD"
        case .detached: "Producer reported detached HEAD"
        case .unborn: "Producer reported unborn branch"
        }
    }

    private func remoteLabel(_ value: ManagedWorkspaceProductGUIPresentation.ReportedRemotePresence) -> String {
        switch value {
        case .producerReportedNone: "Producer reported no remote entries"
        case .producerReportedPresent: "Producer reported one or more remote entries"
        }
    }

    private func comparisonLabel(_ value: ManagedWorkspaceProductGUIPresentation.CachedComparison) -> String {
        switch value {
        case .notRecorded:
            "Not recorded"
        case .producerReported(let ahead, let behind):
            "Producer reported ahead \(ahead) · behind \(behind)"
        }
    }

    private var rejectionMessage: String? {
        guard case .rejected(let rejection) = importState else { return nil }
        switch rejection {
        case .applicationNotAdmitted:
            return "Application identity did not admit snapshot import. No file chooser or filesystem read was entered."
        case .fileUnavailable:
            return "The selected file could not be admitted for a bounded read. No prior presentation was retained."
        case .invalidSnapshot:
            return "The selected bytes were not a valid Prime snapshot. No fields entered the interface."
        case .changedDuringRead:
            return "The selected file changed during the descriptor-held read. The result was discarded."
        case .projectionRejected:
            return "The normalized observation did not satisfy the product projection boundary. The result was discarded."
        case .cancelled:
            return "The assessment was cancelled. Its worker returned and postflight settled before the lease was released."
        case .assessmentUnavailable:
            return "The assessment owner is unavailable after a lifecycle failure. Restart the app before importing another snapshot."
        }
    }

    private var isImporting: Bool {
        importState == .importing
    }

    private func notice(_ text: String, symbol: String, tone: Color) -> some View {
        Label(text, systemImage: symbol)
            .font(.callout)
            .foregroundStyle(tone)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(tone.opacity(0.09), in: RoundedRectangle(cornerRadius: 9))
            .accessibilityElement(children: .combine)
    }

    private var footer: some View {
        Label(
            "Presentation only · imported local data · no live Git, GitHub, network, VM, persistence, or authority promotion",
            systemImage: "lock.shield"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .accessibilityLabel("Presentation only. No live Git, network, virtual machine, persistence, or authority promotion.")
    }
}
