import SwiftUI

@MainActor
struct ProvenanceView: View {
    @ObservedObject var model: ProvenanceModel
    @ObservedObject var lab: HypervisorModel
    @State private var selection = "Hypervisor lab"
    private let accent = Color(red: 0.36, green: 0.86, blue: 0.76)
    private let sections = ["Overview", "Hypervisor lab", "Historical receipts", "Graph bytes", "VM & repository"]

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 24) {
                Label("ERGENTICS", systemImage: "seal")
                    .font(.system(size: 14, weight: .semibold)).tracking(2)
                Text("Provenance").font(.title2)
                ForEach(sections, id: \.self) { section in
                    Button { selection = section } label: {
                        Text(section).frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(selection == section ? accent.opacity(0.12) : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }.buttonStyle(.plain)
                }
                Spacer()
                Label("Local development", systemImage: "lock.shield")
                Text("No virtual NIC\nNo network entitlements")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(24).frame(width: 225)
            .background(Color(red: 0.065, green: 0.083, blue: 0.094))
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("LOCAL / OFFLINE / DEVELOPMENT")
                                .font(.caption).tracking(2).foregroundStyle(accent)
                            Text(selection == "Overview" ? "Ergentics Provenance" : selection)
                                .font(.largeTitle.weight(.semibold))
                        }
                        Spacer()
                        Image(systemName: selection == "Hypervisor lab" ? "cpu" : "doc.text.magnifyingglass").font(.largeTitle).foregroundStyle(accent)
                    }
                    if selection == "Overview" {
                        identityPanel
                        HypervisorLabView(lab: lab, admitted: model.admitted)
                        historyPanel
                    } else if selection == "Hypervisor lab" {
                        HypervisorLabView(lab: lab, admitted: model.admitted)
                        vmPanel
                    } else if selection == "Historical receipts" {
                        historyPanel
                        receiptsPanel
                    } else if selection == "Graph bytes" {
                        graphPanel
                    } else {
                        vmPanel
                        repositoryPanel
                    }
                    if selection != "Hypervisor lab" {
                        Text("Viewer identity ≠ historical producer identity. No authority is transferred by opening these files.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }.padding(28).frame(maxWidth: 1180, alignment: .leading)
            }
        }
        .background(Color(red: 0.048, green: 0.064, blue: 0.075))
        .tint(accent)
    }

    private var identityPanel: some View {
        panel("APPLICATION IDENTITY") {
            Text("com.ergentics.provenance").font(.system(.title3, design: .monospaced))
            Text(model.signingStatus).foregroundStyle(model.admitted ? accent : .orange)
            Text("Configured developer team: \(model.team)").font(.caption).textSelection(.enabled)
            Text("App Sandbox + explicit user-selected read-only history access. New development runs are retained separately by the host; no network entitlement or historical evidence mutation.")
                .foregroundStyle(.secondary)
        }
    }

    private var historyPanel: some View {
        panel("HISTORICAL RESULT") {
            HStack {
                Text(model.snapshot == nil ? "No historical result admitted" : "Historical STATIC PASS · bytes verified")
                    .font(.title3).foregroundStyle(model.snapshot == nil ? .secondary : accent)
                Spacer()
                if model.busy { ProgressView().controlSize(.small) }
                Button("Open retained receipts…") { Task { await model.selectHistory() } }
                    .disabled(!model.admitted || model.busy)
            }
            Text(model.selectedHistory).font(.caption).textSelection(.enabled)
            Text("Select the existing native-static-177403f-r1 folder. It is read in place; no copy, rewrite, migration, retry or new computation occurs.")
                .foregroundStyle(.secondary)
            if let snapshot = model.snapshot {
                Divider()
                Text("12 / 12 pinned artifacts · all manifest hashes and sizes match · three retained graphs are byte-identical")
                Text("Original producer: com.ergentics.PrivateCompute")
                Text("Historical interval: \(snapshot.elapsed)").font(.system(.body, design: .monospaced))
                Text("Raw ticks through historical leaf persistence; not this viewer's duration, CPU time or energy. Energy: not measured (ergs).")
                    .font(.caption).foregroundStyle(.secondary)
                commitment("Recorded Merkle root", snapshot.merkleRoot)
                commitment("Recorded semantic root", snapshot.semanticRoot)
                Text("Commitments are read from pinned historical bytes—not reconstructed or re-executed here.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let error = model.error {
                Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(.red).textSelection(.enabled)
            }
        }
    }

    private var vmPanel: some View {
        panel("HYPERVISOR FRAMEWORK · CAPABILITY QUERIES ONLY") {
            if let capability = model.hypervisor {
                Text("Host support: " + (capability.support_error == 0 ? String(capability.host_supported) : "unobserved (error \(capability.support_error))"))
                Text("sysctl return: \(capability.support_status) · returned bytes: \(capability.support_size)")
                Text("Capability calls entered: \(capability.queries_entered)")
                Text("vCPU limit: " + (capability.queries_entered == 2 && capability.vcpu_status == 0 ? String(capability.max_vcpus) : "unobserved") + " · return " + (capability.queries_entered == 2 ? String(format: "0x%08x", UInt32(bitPattern: capability.vcpu_status)) : "not entered"))
                Text("Maximum IPA width: " + (capability.queries_entered == 2 && capability.ipa_status == 0 ? "\(capability.max_ipa_bits) bits" : "unobserved") + " · return " + (capability.queries_entered == 2 ? String(format: "0x%08x", UInt32(bitPattern: capability.ipa_status)) : "not entered"))
            } else { Text("No Hypervisor capability query has been admitted.") }
            Text("These are support/limit queries, not execution counters. The Hypervisor lab separately records each fixed guest run.")
                .font(.system(.caption, design: .monospaced)).lineSpacing(5)
            Text("A vCPU limit is not a created CPU; IPA width is not allocated RAM. The fixed guest has no OS disk, network adapter or installer.")
                .foregroundStyle(.secondary)
            Text("Apple Private Cloud Compute is a separate service. Account entitlements are not proof that this app is running a VM or using PCC.")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private var repositoryPanel: some View {
        panel("LOCAL ERGENTICS-PRIME · OPTIONAL REFERENCE") {
            Text(model.repositoryReference).font(.system(.body, design: .monospaced)).textSelection(.enabled)
            Button("Select local checkout reference…") { model.selectRepositoryReference() }
                .disabled(!model.admitted || model.busy)
            Text("Selection records a path label in memory only. No files are enumerated, no source identity is admitted, no GitHub request occurs, and no repository is mounted into a guest.")
                .foregroundStyle(.secondary)
        }
    }

    private var receiptsPanel: some View {
        panel("READ-ONLY SNAPSHOT INVENTORY") {
            if let snapshot = model.snapshot {
                ForEach(snapshot.entries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack { Text(entry.name); Spacer(); Text("\(entry.bytes) bytes") }
                        Text(entry.sha256).font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                    }.textSelection(.enabled)
                    Divider()
                }
                Text("Snapshot-time joins only. Descriptors, mode and vnode identities were checked across capture; no ongoing watch or ancestry-wide continuity is claimed.")
                    .font(.caption).foregroundStyle(.secondary)
            } else { Text("Choose the historical receipt folder first.").foregroundStyle(.secondary) }
        }
    }

    private var graphPanel: some View {
        panel("EXACT RETAINED GRAPH · NO RECONSTRUCTION") {
            if let snapshot = model.snapshot {
                commitment("Graph SHA-256", snapshot.graphHash)
                Text(String(decoding: snapshot.graph, as: UTF8.self))
                    .font(.system(.caption, design: .monospaced)).textSelection(.enabled)
            } else { Text("No graph bytes have been admitted.").foregroundStyle(.secondary) }
        }
    }

    private func commitment(_ label: String, _ hash: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(hash).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
        }
    }
    private func panel<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            Text(title).font(.caption.weight(.semibold)).tracking(1.2).foregroundStyle(accent)
            content()
        }
        .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.035)).clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08)))
    }
}
