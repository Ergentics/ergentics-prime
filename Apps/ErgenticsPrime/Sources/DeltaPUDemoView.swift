import SwiftUI

@MainActor
struct DeltaPUDemoView: View {
    @ObservedObject var model: DeltaPUDemoModel
    #if DEBUG
    var readiness: DeltaPUGUIReadiness? = nil
    #endif
    @State private var scenario: DeltaPUDemoScenario = .sparse
    @State private var filter: NodeFilter = .all
    private let accent = Color(red: 0.36, green: 0.86, blue: 0.76)

    private enum NodeFilter: String, CaseIterable, Identifiable {
        case all = "All nodes"
        case changed = "Changed values"
        case affected = "Affected"
        case reused = "Cached"
        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                controls
                if let report = model.report {
                    result(report)
                } else {
                    emptyState
                }
                if let message = model.failureMessage {
                    Label(message, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red).textSelection(.enabled)
                }
                scope
            }
            .padding(28).frame(maxWidth: 1180, alignment: .leading)
        }
        .onDisappear { model.cancel() }
        .accessibilityIdentifier("deltapu-demonstration")
        .background { readinessMarker("page", report: model.report) }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("ΔPU · CHANGE-DRIVEN COMPUTATION")
                    .font(.caption.weight(.semibold)).tracking(1.5).foregroundStyle(accent)
                Text("Compute the change.").font(.largeTitle.weight(.semibold))
                Text("A bounded native Swift CPU reference for the dynamic processing unit.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "arrow.triangle.branch")
                .font(.largeTitle).foregroundStyle(accent)
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Fixed demonstration", selection: $scenario) {
                ForEach(DeltaPUDemoScenario.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented).disabled(model.busy)
            .accessibilityIdentifier("deltapu-scenario")
            Text(scenario.detail).font(.callout).foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Button {
                    model.run(scenario)
                } label: {
                    Label("Run selected demo", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent).disabled(model.busy)
                .accessibilityIdentifier("deltapu-run")
                if model.busy {
                    Button("Cancel") { model.cancel() }
                        .disabled(model.phase == .cancelling)
                        .accessibilityIdentifier("deltapu-cancel")
                    ProgressView().controlSize(.small)
                }
                Button("Clear in-memory result") { model.clear() }
                    .disabled(model.busy || model.phase == .idle)
                    .accessibilityIdentifier("deltapu-clear")
                Spacer(minLength: 0)
                Text(model.phase.rawValue).font(.caption).foregroundStyle(.secondary)
            }
            Text("One 64-node graph and one fixed edit per click. No automatic runs, VM, input file or benchmark loop.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(18).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .disabled(DevelopmentLaunch.deltaPUReadinessRequested)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(model.phase == .cancelled ? "No result published." : "No computation result yet.")
                .font(.title3.weight(.medium))
            Text(model.phase == .cancelled
                 ? "Cancellation suppresses publication. You can run a fresh synthetic demonstration."
                 : "Choose a fixture and press Run. Opening this page does not start computation.")
                .foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
    }

    private func result(_ report: DeltaPUDemoReport) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Label("Rendered CPU result", systemImage: "waveform.path")
                    .font(.title3.weight(.semibold)).foregroundStyle(accent)
                    .accessibilityIdentifier("deltapu-result-status")
                Spacer()
                Text("Result: \(report.scenario.title)").font(.callout)
            }
            .background { readinessMarker("result", report: report) }
            Text("The exact fixture, submitted edit, output delta, reconstructed values and state commitments agree.")
                .font(.callout).foregroundStyle(.secondary)
            Text(report.scope.rawValue).font(.caption.weight(.semibold))
                .accessibilityIdentifier("deltapu-result-scope")
            DeltaPUMetricLayout(sourceStateID: report.transition.snapshot.stateID) {
                metric("Incremental evaluations", report.transition.work.nodesEvaluated)
                metric("Full evaluations per verifier pass", report.verification.afterNodeEvaluations)
                metric("Cached values reused", report.transition.work.valuesReused)
            }
            .clipped()
            Text("Operation counts, not CPU time or energy. Verification runs before the in-memory update and again before report construction. Each pass also recomputes the \(report.verification.beforeNodeEvaluations)-node baseline. Counts shown cover one verifier pass; full graph validation, copying, output comparison and hashing remain.")
                .font(.caption).foregroundStyle(.secondary)

            HStack {
                Text("NODE DELTA").font(.caption.weight(.semibold)).tracking(1)
                Spacer()
                Picker("Node filter", selection: $filter) {
                    ForEach(NodeFilter.allCases) { item in Text(item.rawValue).tag(item) }
                }
                .pickerStyle(.segmented).frame(maxWidth: 410)
                .disabled(DevelopmentLaunch.deltaPUReadinessRequested)
            }
            Table(rows(report)) {
                TableColumn("Node") { row in Text(String(row.id)).monospacedDigit() }.width(50)
                TableColumn("Before") { row in Text(number(row.oldValue)).monospacedDigit() }
                TableColumn("After") { row in Text(number(row.newValue)).monospacedDigit() }
                TableColumn("Value / dependency status") { row in
                    Text(row.status.rawValue)
                        .foregroundStyle(row.status == .reused ? Color.secondary : accent)
                }
                TableColumn("Definition") { row in
                    Text(row.definitionChanged ? "Edited" : "Unchanged").foregroundStyle(.secondary)
                }
            }
            .frame(height: 340)
            .accessibilityIdentifier("deltapu-node-table")
            .background { readinessMarker("table", report: report, rowIDs: rows(report).map(\.id)) }
            Text("Affected and cached membership is independently derived from old/new dependencies—not a per-node processor trace. An affected value can remain numerically unchanged.")
                .font(.caption).foregroundStyle(.secondary)

            DisclosureGroup("Work accounting") {
                Grid(alignment: .leading, horizontalSpacing: 22, verticalSpacing: 7) {
                    workRow("Submitted edits", report.transition.work.submittedEdits)
                    workRow("Changed definitions", report.transition.work.changedDefinitions)
                    workRow("Nodes validated", report.transition.work.nodesValidated)
                    workRow("Operand occurrences validated", report.transition.work.operandEdgesValidated)
                    workRow("Surviving affected nodes", report.transition.work.invalidatedNodes)
                    workRow("Union dependency edges visited", report.transition.work.invalidationEdgesVisited)
                    workRow("Incremental operand reads", report.transition.work.operandReads)
                    workRow("Full after-state reads per verifier pass", report.verification.afterOperandReads)
                    workRow("Output IDs compared", report.transition.work.outputComparisons)
                    workRow("Commitment payload bytes", report.transition.work.commitmentPayloadBytes)
                }.font(.caption).padding(.top, 8)
                Text("Payload bytes exclude hash framing, independent verification and memory-copy costs.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            DisclosureGroup("Exact output delta · \(report.transition.outputDelta.count) edits") {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(report.transition.outputDelta.enumerated()), id: \.offset) { _, edit in
                        Text(output(edit)).font(.system(.caption, design: .monospaced))
                    }
                }.textSelection(.enabled).padding(.top, 8)
            }
            DisclosureGroup("State ancestry and exact CBOR") {
                VStack(alignment: .leading, spacing: 12) {
                    identity("Before / parent state", report.before.stateID)
                    identity("Submitted delta", report.transition.deltaID)
                    identity("After content Merkle root", report.transition.snapshot.contentRoot)
                    identity("After state · revision \(report.transition.snapshot.revision)", report.transition.snapshot.stateID)
                    bytes("Submitted delta CBOR", report.transition.deltaCBOR)
                    bytes("After content CBOR", report.transition.snapshot.contentCBOR)
                    bytes("After version CBOR", report.transition.snapshot.versionCBOR)
                }.padding(.top, 8)
            }
        }
        .padding(18).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder private func readinessMarker(_ role: String, report: DeltaPUDemoReport?,
                                             rowIDs: [UInt32]? = nil) -> some View {
        #if DEBUG
        if let readiness {
            DeltaPUGUIReadinessMarker(observer: readiness, role: role,
                                      stateID: report?.transition.snapshot.stateID ?? "",
                                      rowIDs: rowIDs ?? report?.verification.rows.map(\.id) ?? [])
                .allowsHitTesting(false).accessibilityHidden(true)
        }
        #endif
    }

    private var scope: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label("Synthetic development computation · in memory only", systemImage: "info.circle")
            Text("This pure fixture does not require or grant app admission. Existing signature gates for guest execution and file imports remain separate. No ΔPU files are written; Clear and Quit may discard this result.")
            Text("The GUI renders checked source data; it does not grant authority. Every demo result is diagnostic-only, including debugger-derived observations. This path does not detect debugger attachment or produce authoritative commits.")
            Text("ΔPU is the proposed dynamic/change-processing unit, not a networking data-processing unit. No GPU replacement, host integrity, Gate E or distribution acceptance is established. Energy is unmeasured (ergs).")
        }.font(.caption).foregroundStyle(.secondary)
    }

    private func rows(_ report: DeltaPUDemoReport) -> [DeltaPUVerifiedNode] {
        report.verification.rows.filter { row in
            switch filter {
            case .all: true
            case .changed: row.status == .changed || row.status == .removed
            case .affected: row.status != .reused
            case .reused: row.status == .reused
            }
        }
    }

    private func metric(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(String(value)).font(.largeTitle.weight(.medium)).monospacedDigit()
                .fixedSize(horizontal: false, vertical: true)
        }.padding(14)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity,
                   alignment: .topLeading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 9))
            .clipped()
    }

    private func workRow(_ title: String, _ value: Int) -> some View {
        GridRow { Text(title); Text(String(value)).monospacedDigit() }
    }

    private func identity(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
        }
    }

    private func bytes(_ title: String, _ value: Data) -> some View {
        DisclosureGroup("\(title) · \(value.count) bytes") {
            Text(value.map { String(format: "%02x", $0) }.joined())
                .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
        }
    }

    private func number(_ value: Int64?) -> String { value.map(String.init) ?? "—" }
    private func output(_ edit: DeltaPUOutputEdit) -> String {
        switch edit {
        case .set(let id, let value): "set \(id) = \(value)"
        case .remove(let id): "remove \(id)"
        }
    }
}

/// Presentation adapter only. It neither reconstructs nor validates source state.
private struct DeltaPUMetricLayout: Layout {
    let sourceStateID: String

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // The minimum probe uses the preferred one-column width; positive
        // narrower proposals are also supported. Ideal/maximum probes are bounded.
        let width: Double
        switch proposal.width {
        case nil: width = DeltaPULayoutPlanner.idealWidth
        case .some(0): width = DeltaPULayoutPlanner.minimumCardWidth
        case .some(.infinity): width = DeltaPULayoutPlanner.maxExtent
        case .some(let value): width = Double(value)
        }
        guard let plan = measure(width: width, subviews: subviews) else { return .zero }
        return CGSize(width: plan.width, height: plan.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize,
                       subviews: Subviews, cache: inout ()) {
        guard bounds.origin.x.isFinite, bounds.origin.y.isFinite,
              bounds.height.isFinite, bounds.maxX.isFinite, bounds.maxY.isFinite,
              bounds.maxX > bounds.minX, bounds.maxY > bounds.minY,
              let plan = measure(width: Double(bounds.width), subviews: subviews),
              plan.height <= Double(bounds.height), plan.clipsToBounds else {
            placeEmpty(subviews)
            return
        }
        let frames = plan.cards.map { rect in
            CGRect(x: bounds.minX + rect.x, y: bounds.minY + rect.y,
                   width: rect.width, height: rect.height)
        }
        // Translation must also preserve finite positive extents and separation.
        // Finite local geometry alone cannot guarantee representable parent coordinates.
        for (index, frame) in frames.enumerated() {
            guard frame.minX.isFinite, frame.minY.isFinite,
                  frame.maxX.isFinite, frame.maxY.isFinite,
                  frame.maxX > frame.minX, frame.maxY > frame.minY,
                  frame.minX >= bounds.minX, frame.minY >= bounds.minY,
                  frame.maxX <= bounds.maxX, frame.maxY <= bounds.maxY else {
                placeEmpty(subviews); return
            }
            for other in frames.dropFirst(index + 1) {
                guard frame.maxX <= other.minX || other.maxX <= frame.minX
                    || frame.maxY <= other.minY || other.maxY <= frame.minY else {
                    placeEmpty(subviews); return
                }
            }
        }
        for (index, subview) in subviews.enumerated() {
            let frame = frames[index]
            subview.place(at: frame.origin, anchor: .topLeading,
                          proposal: ProposedViewSize(width: frame.width, height: frame.height))
        }
    }

    private func placeEmpty(_ subviews: Subviews) {
        // The three callers have an outer zero-minimum/unbounded-maximum frame
        // in both dimensions, followed by clipping. This is not a generic Layout
        // guarantee that arbitrary subviews must accept a zero proposal.
        for subview in subviews { subview.place(at: .zero, anchor: .topLeading, proposal: .zero) }
    }

    private func measure(width: Double, subviews: Subviews) -> DeltaPULayoutPlanner.Plan? {
        guard subviews.count == 3,
              let proposal = DeltaPULayoutPlanner.prepare(viewportWidth: width) else { return nil }
        var heights: [Double] = []
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(ProposedViewSize(width: proposal.cardWidths[index], height: nil))
            guard Double(size.width) == proposal.cardWidths[index] else { return nil }
            heights.append(Double(size.height))
        }
        return DeltaPULayoutPlanner.generate(sourceStateID: sourceStateID, proposal: proposal, heights: heights)
    }
}
