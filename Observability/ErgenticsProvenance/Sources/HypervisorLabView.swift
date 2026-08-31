import SwiftUI

@MainActor
struct HypervisorLabView: View {
    @ObservedObject var lab: HypervisorModel
    let admitted: Bool
    private let accent = Color(red: 0.36, green: 0.86, blue: 0.76)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("HYPERVISOR LAB · FIXED AARCH64 GUEST")
                .font(.caption.weight(.semibold)).tracking(1.2).foregroundStyle(accent)
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("One guest. One change boundary.").font(.title2.weight(.semibold))
                    Text("19 + 23 → 42 · MMIO doorbell · two 32-byte mailboxes")
                        .font(.system(.caption, design: .monospaced))
                }
                Spacer()
                if lab.busy { ProgressView().controlSize(.small) }
                Button("Run fixed guest") { lab.run(admitted: admitted) }
                    .disabled(!admitted || lab.busy || lab.quarantined)
                    .accessibilityIdentifier("run-fixed-guest")
                if lab.busy { Button("Request cancellation") { lab.cancel() } }
            }
            Text(lab.phase).foregroundStyle(lab.busy ? .orange : .secondary)
            Text("Idle until Run. No virtual NIC, network, guest disk or background watchdog.")
                .font(.callout).foregroundStyle(.secondary)
            if let result = lab.result { resultView(result) }
            if let error = lab.error { Text(error).foregroundStyle(.red).textSelection(.enabled) }
            Divider()
            HStack {
                Text("HOST PERSISTENCE · DETERMINISTIC CBOR IN SQLITE").font(.caption.weight(.semibold))
                Spacer()
                Button("Verify retained runs") { lab.refresh() }.disabled(lab.busy || !admitted)
            }
            Text(lab.journalURL.path).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
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
                    Text("One vCPU runs the bundled image once and exits at its MMIO doorbell. A temporary sleeping watchdog requests vCPU exit after two seconds and is joined before completion; kernel acknowledgment has no guaranteed time bound. No process signal is used.")
                    Text("PASS means local guest/transport mechanics, not ΔPU acceleration, hardware attestation or scientific Gate E closure. Gate E remains ABSTAIN; authority vector 00000000. Energy is unmeasured (ergs).")
                }.font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.035)).clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08)))
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
}
