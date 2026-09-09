import SwiftUI

@MainActor
struct HypervisorLabView: View {
    @ObservedObject var lab: HypervisorModel
    let admitted: Bool
    private let accent = Color(red: 0.36, green: 0.86, blue: 0.76)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("HYPERVISOR LAB · NATIVE AARCH64 EXECUTION")
                .font(.caption.weight(.semibold)).tracking(1.2).foregroundStyle(accent)
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Checkpoint execution and receipts").font(.title2.weight(.semibold))
                    Text("H2 is a separate fixed-guest journal mode")
                        .font(.system(.caption, design: .monospaced))
                }
                Spacer()
                if lab.busy || lab.retentionProvisioning || lab.historyReconstructing {
                    ProgressView().controlSize(.small)
                }
                if lab.busy {
                    Button("Stop") { lab.cancel() }
                    Button("Quit Now") { lab.quitNow() }
                }
            }
            h7View
            h8View
            h5View
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("H3 · live checkpoint and resume").font(.headline)
                        Spacer()
                        Button(lab.h3Running ? "Running H3 cursor resume…" : "Run H3 cursor resume") {
                            lab.runH3CursorResume(admitted: admitted)
                        }
                        .disabled(!admitted || !lab.canRunH3CursorResume)
                        .accessibilityIdentifier("run-h3-cursor-resume")
                        .accessibilityLabel("Run H3 cursor resume")
                        .accessibilityHint("Runs one in-memory checkpoint and one fixed fresh VM and vCPU resume interval. Verified receipt bytes remain in memory; no journal is opened.")
                    }
                    Text(lab.h3ModeStatus).font(.caption).foregroundStyle(.secondary)
                    if let result = lab.h3Result { h3ResultView(result) }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("H2 · fixed guest with private journal").font(.headline)
                        Spacer()
                        if !lab.retentionGranted && !lab.historyDisplayGranted {
                            Button(lab.retentionProvisioning ? "Creating private journal…" : "Create private journal") {
                                Task { await lab.provisionPrivateJournal(admitted: admitted) }
                            }
                            .disabled(!admitted || !lab.canProvisionRetention)
                            .accessibilityIdentifier("create-private-journal")
                            .accessibilityLabel("Create private journal")
                            .accessibilityHint("Permanently creates the app's one fixed private evidence root. It does not run the guest.")
                            .help("Creates one fixed private Application Support root. Existing or partial state is retained and never adopted by Create.")
                        }
                        Button("Run fixed guest") { lab.run(admitted: admitted) }
                            .disabled(!admitted || !lab.retentionGranted || lab.busy || lab.quarantined)
                            .accessibilityIdentifier("run-fixed-guest")
                    }
                    Text("19 + 23 → 42 · fixed guest · explicit retention required")
                        .font(.system(.caption, design: .monospaced))
                    Text(lab.retentionStatus).font(.caption).foregroundStyle(.secondary)
                        .accessibilityLabel("Private journal status")
                        .accessibilityValue(lab.retentionStatus)
                    if let result = lab.result { resultView(result) }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("H4 · retain this live H3 receipt").font(.headline)
                        Spacer()
                        Button(lab.h4Saving ? "Saving and verifying…" : "Save H3 receipt to private SQLite") {
                            lab.saveH4Receipt(admitted: admitted)
                        }
                        .disabled(!admitted || !lab.canSaveH4Receipt)
                        .accessibilityIdentifier("save-live-h4-receipt")
                        .help("One explicit save of this native H3 result. Creates a fresh private receipt directory, never overwrites old evidence. Ten-second work budget, then the existing five-second app-only Stop fallback.")
                    }
                    Text("After H3 PASS, Save retains its state/graph JSON and CBOR, including run timing and hashes, in a new private SQLite image. Nothing is exported. No raw failure diagnostic, VM handle, or execution authority is stored.")
                        .font(.caption).foregroundStyle(.secondary)
                    if let saved = lab.h4Result {
                        Text(saved.durable ? "SAVED · VERIFIED READ-BACK" : "NOT VERIFIED · STATE RETAINED")
                            .font(.headline).foregroundStyle(saved.durable ? accent : .orange)
                        Text(saved.detail).font(.caption)
                        if !saved.location.isEmpty {
                            Text(saved.location).font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                        }
                        if let receipt = saved.receipt {
                            Text("H4 receipt · \(receipt.root)\nSource H3 receipt · \(receipt.h3ReceiptRoot)")
                                .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                            Text("Durable yes · Gate E ABSTAIN · authority 00000000 · no OS attestation")
                                .font(.caption).foregroundStyle(.secondary)
                            DisclosureGroup("Saved H4 JSON · \(receipt.json.count) bytes") {
                                Text(String(decoding: receipt.json, as: UTF8.self))
                                    .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                            }
                            DisclosureGroup("Saved H4 CBOR · \(receipt.cbor.count) bytes · hexadecimal") {
                                Text(receipt.cbor.map { String(format: "%02x", $0) }.joined())
                                    .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                            }
                        }
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("H4 · inspect a saved receipt").font(.headline)
                        Spacer()
                        Button(lab.h4Opening ? "Opening saved receipt…" : "Open saved H4 receipt…") {
                            lab.openSavedH4Receipt(admitted: admitted)
                        }
                        .disabled(!admitted || !lab.canOpenH4Receipt)
                        .accessibilityIdentifier("open-saved-h4-receipt")
                    }
                    Text("Select one saved SQLite file, including after relaunch. No automatic scan, guest run, new save, repair, or restored authority.")
                        .font(.caption).foregroundStyle(.secondary)
                    if let opened = lab.h4Opened {
                        Text("REOPENED · SAVED DATA VERIFIED").font(.headline).foregroundStyle(accent)
                            .accessibilityIdentifier("h4-reopened-status")
                        Text("Recorded H3 PASS → H4 file present → read-only integrity verified")
                            .font(.caption.weight(.semibold))
                        Text(opened.location).font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                        Text("H4 root · \(opened.receipt.root)\nSource H3 root · \(opened.receipt.h3.root)")
                            .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                        Text("Recorded native interval · \(opened.receipt.interval)")
                            .font(.system(.caption, design: .monospaced))
                        Text("SQLite · \(opened.imageBytes) bytes · SHA-256 \(opened.imageSHA256)")
                            .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                        Text("Both canonical streams, H3 state/graph relationships and stored indexes were checked. This verifies saved data, not a new execution or independent OS origin. A wholly replaced, internally valid receipt requires an external expected root to distinguish it. Gate E ABSTAIN · authority 00000000.")
                            .font(.caption).foregroundStyle(.secondary)
                        DisclosureGroup("Reopened H4 JSON · \(opened.receipt.json.count) bytes") {
                            Text(String(decoding: opened.receipt.json, as: UTF8.self))
                                .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                        }
                        DisclosureGroup("Reopened H4 CBOR · \(opened.receipt.cbor.count) bytes · hexadecimal") {
                            Text(opened.receipt.cbor.map { String(format: "%02x", $0) }.joined())
                                .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                        }
                        DisclosureGroup("Inspect recorded H3 state and graph") {
                            receiptProjection("H3 state", opened.receipt.h3.state)
                            receiptProjection("H3 graph", opened.receipt.h3.graph)
                        }
                    }
                    if let failure = lab.h4OpenError {
                        Text("NOT VERIFIED · SELECTED FILE UNCHANGED").font(.headline).foregroundStyle(.orange)
                        Text(failure).font(.caption).textSelection(.enabled)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            Text(lab.phase).foregroundStyle(lab.busy ? .orange : .secondary)
            if lab.busy {
                Text("Stop allows five seconds to finish, then closes this whole app. Quit Now exits immediately. Committed evidence stays; unsaved memory may be lost. Neither action signals another process.")
                    .font(.caption).foregroundStyle(.orange)
            }
            Text("Checkpoint storage opens only after Create, Open, or Save. H2 journals, H4 receipts and H8 provenance use separate locations. These fixed guest tests have no virtual network or disk.")
                .font(.callout).foregroundStyle(.secondary)
            if let error = lab.error { Text(error).foregroundStyle(.red).textSelection(.enabled) }
            Divider()
            HStack {
                Text("HISTORY · RETAINED H2 EVIDENCE, READ-ONLY").font(.caption.weight(.semibold))
                Spacer()
                if lab.historyDisplayGranted {
                    Button("Show granted history") { lab.refresh() }
                        .disabled(lab.busy || !admitted)
                } else {
                    Button(lab.historyReconstructing ? "Opening fixed evidence…" : "Open existing evidence read-only") {
                        Task { await lab.reconstructPrivateJournalHistory(admitted: admitted) }
                    }
                    .disabled(!admitted || !lab.canReconstructHistory)
                    .accessibilityIdentifier("open-existing-evidence-read-only")
                    .accessibilityLabel("Open existing evidence read-only")
                    .accessibilityHint("Reads only the app's fixed private journal into an immutable verified snapshot. It grants no retention or guest execution authority.")
                    .help("No directory enumeration, creation, recovery, checkpoint, guest run, or authority restoration.")
                }
            }
            Text(lab.historyDisplayStatus).font(.caption).foregroundStyle(.secondary)
            Text("H3 and H7 results stay in memory until you use their Save action. Opening historical evidence does not restore a running guest or a Save capability.")
                .font(.caption).foregroundStyle(.secondary)
            ForEach(lab.recent) { item in
                DisclosureGroup {
                    resultView(item)
                } label: {
                    HStack {
                        Text(item.status).foregroundStyle(item.status == "PASS" ? accent : .orange)
                        Text(item.id).font(.system(.caption, design: .monospaced))
                        Spacer()
                        Text("\(item.events.count) events").font(.caption)
                    }
                }
            }
            DisclosureGroup("Runtime bounds and evidence scope") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("One vCPU runs the bundled image once and exits at its MMIO doorbell. The native watchdog requests vCPU exit after two seconds. Separately, user Stop/Quit starts a five-second grace period. Unfinished Stop or pending Quit then exits only this app; a normal-termination request does not remove the Quit fallback. Scheduling/kernel latency has no absolute guarantee, and evidence publication cannot veto exit.")
                    Text("PASS means local guest/transport mechanics, not ΔPU acceleration, hardware attestation or scientific Gate E closure. Gate E remains ABSTAIN; authority vector 00000000. Energy is unmeasured (ergs).")
                }.font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.separator.opacity(0.55)))
    }

    private var h8View: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("H8 · retained checkpoint provenance").font(.headline)
                    Spacer()
                    Button(lab.h8Saving ? "Saving provenance…" : "Save H7 provenance") {
                        lab.saveH8Provenance(admitted: admitted)
                    }
                    .disabled(!admitted || !lab.canSaveH8)
                    .accessibilityIdentifier("save-h8-provenance")
                    Button("Open saved H8 provenance…") { lab.openH8Provenance(admitted: admitted) }
                        .disabled(!admitted || !lab.canOpenH8)
                        .accessibilityIdentifier("open-h8-provenance")
                }
                Text("Save retains this checkpoint’s verified state, timing and lineage in a new private file until you remove it. Save is available for five minutes after H7. Reopening grants 60 seconds of read-only inspection.")
                    .font(.caption).foregroundStyle(.secondary)
                if let saved = lab.h8Saved {
                    Text(saved.durable ? "H8 SAVED · LINEAGE VERIFIED" : "H8 SAVE INCOMPLETE · EVIDENCE PRESERVED")
                        .font(.headline).foregroundStyle(saved.durable ? accent : .orange)
                    Text(saved.location).font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                    if let projection = saved.projection {
                        Text("Saved H8 root · \(projection.root)\nSource H3 root · \(projection.h3.root)")
                            .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                    }
                }
                Text(lab.h8ReadStatus).font(.caption.weight(.semibold))
                    .accessibilityIdentifier("h8-read-status")
                if let opened = lab.h8Opened {
                    Text("H8 READ · LINEAGE VERIFIED").font(.headline).foregroundStyle(accent)
                    Text("H8 root · \(opened.projection.root)\nH3 ancestor · \(opened.projection.h3.root)\nState ancestor · \(opened.projection.h3.state.root)\nGraph ancestor · \(opened.projection.h3.graph.root)")
                        .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                    Text("Recorded run \(opened.projection.epoch.uuidString.lowercased()) · \(opened.imageBytes) saved bytes")
                        .font(.caption)
                    Button("Revoke read grant") { lab.revokeH8Read() }
                        .accessibilityIdentifier("revoke-h8-read")
                }
                Text("Saved-data verification grants no execution or trusted egress. Gate E ABSTAIN · authority 00000000. Revocation closes this view; saved files and previously observed copies remain.")
                    .font(.caption).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var h7View: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("H7 · bounded checkpoint execution").font(.headline)
                    Spacer()
                    Button(lab.h7Running ? "Running H7…" : "Run H7 checkpoint") {
                        lab.runH7Checkpoint(admitted: admitted)
                    }
                    .disabled(!admitted || !lab.canRunH3CursorResume)
                    .accessibilityIdentifier("run-h7-checkpoint")
                }
                Text("One fixed function: 19 + 23 → checkpoint 42 → resume 43. One attempt per launch, with a 15-second work budget. Results stay in memory until Quit.")
                    .font(.caption).foregroundStyle(.secondary)
                if let result = lab.h7Result {
                    Text("H7 PASS · BOUNDED CHECKPOINT VERIFIED").font(.headline).foregroundStyle(accent)
                        .accessibilityIdentifier("h7-result-status")
                    Text("Checkpoint \(result.checkpoint) → resumed \(result.resumed) · teardown verified")
                        .font(.system(.caption, design: .monospaced))
                    Text("Local run \(result.epoch.uuidString.lowercased())")
                        .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                    Text("Gate E ABSTAIN · authority 00000000 · no independent OS attestation")
                        .font(.caption).foregroundStyle(.secondary)
                } else if lab.h7Attempted && !lab.h7Running {
                    Text("H7 unavailable · relaunch to begin a new attempt").font(.caption)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var h5View: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("H5 · repeated resume determinism").font(.headline)
                    Spacer()
                    Button(lab.h5Running ? "Running H5 batch…" : "Run H5 · 3 resume pairs") {
                        lab.runH5Repeat(admitted: admitted)
                    }
                    .disabled(!admitted || !lab.canRunH3CursorResume)
                    .accessibilityIdentifier("run-h5-repeat")
                    .accessibilityHint("Runs three sequential fixed H3 checkpoint and resume pairs. Stops on the first failure. Results stay in memory for this launch.")
                }
                Text("Three fresh reservations, six VM intervals: checkpoint 42 → resume 43. One batch per launch, with a 15-second work budget and the existing five-second Stop fallback.")
                    .font(.caption).foregroundStyle(.secondary)
                Text("Guest state and execution results must match. Generation IDs, timing and their dependent hashes vary. This links three local observations; it does not independently attest the host or measure energy. Selecting H5 excludes H3/H2 and storage for this launch.")
                    .font(.caption).foregroundStyle(.secondary)
                if let result = lab.h5Result {
                    Text(result.summary == nil ? "H5 INCOMPLETE · \(result.failure?.rawValue ?? "rejected")" : "H5 PASS · THREE LOCAL RESUME RUNS MATCH")
                        .font(.headline).foregroundStyle(result.summary == nil ? .orange : accent)
                        .accessibilityIdentifier("h5-result-status")
                    Text("\(result.attempted) attempts · \(result.observations.count) accepted observations · Gate E ABSTAIN · authority 00000000")
                        .font(.system(.caption, design: .monospaced))
                    Text("Exposure accumulates across all attempted runs, including incomplete attempts. Accepted observations expose fixed guest state, timing, generations and commitments to this app, GUI and Accessibility. Retention is in memory until Quit; no H5 file is saved.")
                        .font(.caption).foregroundStyle(.secondary)
                    ForEach(result.observations.indices, id: \.self) { index in
                        let observation = result.observations[index]
                        DisclosureGroup("Run \(observation.ordinal) · generations \(observation.presentation.sourceGeneration) → \(observation.presentation.targetGeneration) · \(observation.presentation.elapsed)") {
                            Text("Comparison root: \(observation.comparison.root)")
                                .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                            if let receipt = observation.presentation.receipt {
                                Text("Original H3 receipt root: \(receipt.root)")
                                    .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                                receiptProjection("H3 state", receipt.state)
                                receiptProjection("H3 graph", receipt.graph)
                            }
                            DisclosureGroup("Raw verified cursor evidence · \(observation.evidence.count) bytes") {
                                Text(observation.evidence.map { String(format: "%02x", $0) }.joined())
                                    .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                            }
                        }
                    }
                    if let summary = result.summary {
                        Text("H5 receipt root: \(summary.projection.root)")
                            .font(.system(.caption, design: .monospaced)).textSelection(.enabled)
                            .accessibilityIdentifier("h5-receipt-root")
                        receiptProjection("H5 comparison and cumulative exposure", summary.projection)
                        if let first = summary.observations.first {
                            receiptProjection("Exact deterministic comparison", first.comparison)
                        }
                    }
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func resultView(_ result: GuestPresentation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(result.status).font(.title3.bold()).foregroundStyle(result.status == "PASS" ? accent : .orange)
            Text(result.detail)
            if !result.elapsed.isEmpty {
                Text("Native interval: \(result.elapsed)").font(.system(.caption, design: .monospaced))
                Text("Excludes host journal and UI work; not CPU time or energy.").font(.caption2).foregroundStyle(.secondary)
            }
            if let bytes = result.volatileObservation {
                DisclosureGroup("Recovery observation · \(bytes.count) volatile CBOR bytes · NOT durably published") {
                    Text(bytes.map { String(format: "%02x", $0) }.joined())
                        .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                }
            }
            if !result.root.isEmpty {
                Text(result.status == "PASS" ? "Verified snapshot Merkle root" : "Observed snapshot Merkle root").font(.caption)
                Text(result.root).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
            }
            ForEach(result.events) { event in
                Text("\(event.id) · \(event.kind) · \(event.byteCount) CBOR bytes\n\(event.digest)")
                    .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
            }
        }.padding(.vertical, 5)
    }

    private func h3ResultView(_ result: GuestH3Presentation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(result.status).font(.title3.bold())
                .foregroundStyle(result.status == "PASS" ? accent : .orange)
            Text("Verification disposition · \(result.verificationDisposition)")
                .font(.system(.caption, design: .monospaced))
            Text(result.detail)
            if !result.cursorSHA256.isEmpty {
                Text("Immutable in-memory cursor SHA-256").font(.caption)
                Text(result.cursorSHA256)
                    .font(.system(.caption, design: .monospaced)).textSelection(.enabled)
            }
            if !result.checkpointRoot.isEmpty {
                Text("Checkpoint Merkle · \(result.checkpointRoot)\nTerminal Merkle · \(result.terminalRoot)")
                    .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
            }
            if !result.projectionRoot.isEmpty {
                Text("Verified projection · \(result.projectionRoot)\nVerified graph · \(result.graphRoot)")
                    .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
            }
            if !result.elapsed.isEmpty {
                Text("Native interval: \(result.elapsed)")
                    .font(.system(.caption, design: .monospaced))
                Text("Excludes host verification and UI work; not CPU time or energy.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            Text("Source generation \(result.sourceGeneration) · \(result.sourceRunEntries) entry; target generation \(result.targetGeneration) · \(result.targetRunEntries) entry")
                .font(.system(.caption2, design: .monospaced))
            if let receipt = result.receipt {
                DisclosureGroup("Inspect verified H3 receipt · in memory") {
                    VStack(alignment: .leading, spacing: 8) {
                    Text("Exact H3 JSON and CBOR captured at execution, before Save. The separate H4 card reports whether they were saved. Quit discards this in-memory view, not a saved H4 file. No independent OS attestation or qualification-run envelope is claimed.")
                            .font(.caption).foregroundStyle(.secondary)
                        Text("Receipt root · \(receipt.root)")
                            .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
                        receiptProjection("State", receipt.state)
                        receiptProjection("Graph", receipt.graph)
                    }
                }.accessibilityIdentifier("h3-receipt-inspector")
            }
            if result.quarantined {
                Text("Native conservation was not proven; this application lifetime is quarantined.")
                    .font(.caption).foregroundStyle(.red)
            }
            Text("H3 execution observation · Gate E \(result.gateE) · authority \(result.authorityVector). H4 save and reopen status are shown separately.")
                .font(.caption).foregroundStyle(.secondary)
        }.padding(.vertical, 5)
    }

    private func receiptProjection(_ label: String, _ projection: HypervisorStageProjection) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(label) root · \(projection.root)")
                .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
            DisclosureGroup("\(label) JSON · \(projection.json.count) bytes") {
                Text(String(decoding: projection.json, as: UTF8.self))
                    .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
            }
            DisclosureGroup("\(label) CBOR · \(projection.cbor.count) bytes · hexadecimal") {
                Text(projection.cbor.map { String(format: "%02x", $0) }.joined())
                    .font(.system(.caption2, design: .monospaced)).textSelection(.enabled)
            }
        }
    }
}
