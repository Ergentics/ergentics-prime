import SwiftUI

@MainActor
struct ProvenanceView: View {
    @ObservedObject var model: ProvenanceModel
    @ObservedObject var lab: HypervisorModel
    @ObservedObject var primeRuntime: PrimeRuntimeModel
    @ObservedObject private var primeCompute = PrimeComputeModel.shared
    @ObservedObject var primeGit: PrimeGitModel
    @ObservedObject var deltaPU: DeltaPUDemoModel
    @ObservedObject var virtualMachines: VMWorkspaceModel
    @ObservedObject var gitWorkspace: GitWorkspaceModel
    let windowCaptureBoundaryApplied: Bool?
    #if DEBUG
    var deltaPUReadiness: DeltaPUGUIReadiness? = nil
    #endif

    @State private var selection: Destination =
        DevelopmentLaunch.deltaPUReadinessRequested ? .deltaPU :
        (DevelopmentLaunch.processMode == .primeGitReadiness ? .primeGit : .agents)
    private let accent = Color.teal

    private enum Destination: CaseIterable, Hashable, Identifiable {
        case agents
        case workspace
        case prime
        case virtualMachines
        case gitWorkspace
        case primeGit
        case deltaPU
        case hypervisorLab
        case overview
        case historicalReceipts
        case graphBytes
        case vmAndRepository

        var id: Self { self }
        var title: String {
            switch self {
            case .agents: "Agents"
            case .workspace: "Workspace"
            case .prime: "Prime"
            case .virtualMachines: "Virtual machines"
            case .gitWorkspace: "Git workspace"
            case .primeGit: "Prime Git evidence"
            case .deltaPU: "ΔPU"
            case .hypervisorLab: "Hypervisor lab"
            case .overview: "Overview"
            case .historicalReceipts: "Historical receipts"
            case .graphBytes: "Graph bytes"
            case .vmAndRepository: "Host capabilities"
            }
        }
        var symbol: String {
            switch self {
            case .agents: "text.bubble"
            case .workspace: "square.grid.2x2"
            case .prime: "sparkles"
            case .virtualMachines: "desktopcomputer"
            case .gitWorkspace: "folder.badge.gearshape"
            case .primeGit: "arrow.triangle.branch"
            case .deltaPU: "triangle"
            case .hypervisorLab: "cpu"
            case .overview: "rectangle.grid.2x2"
            case .historicalReceipts: "clock.arrow.trianglehead.counterclockwise.rotate.90"
            case .graphBytes: "point.3.connected.trianglepath.dotted"
            case .vmAndRepository: "externaldrive.badge.timemachine"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section("Work") {
                    ForEach([Destination.agents, .workspace, .gitWorkspace, .virtualMachines, .prime]) { destination in
                        Label(destination.title, systemImage: destination.symbol).tag(destination)
                    }
                }
                Section("Experiments") {
                    ForEach([Destination.hypervisorLab, .deltaPU]) { destination in
                        Label(destination.title, systemImage: destination.symbol).tag(destination)
                    }
                }
                Section("Evidence") {
                    ForEach([Destination.primeGit, .historicalReceipts, .graphBytes, .overview, .vmAndRepository]) { destination in
                        Label(destination.title, systemImage: destination.symbol).tag(destination)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Prime")
            .disabled(DevelopmentLaunch.deltaPUReadinessRequested)
            .navigationSplitViewColumnWidth(min: 210, ideal: 240, max: 290)
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .leading, spacing: 5) {
                    Label("Local workspace", systemImage: "lock.shield")
                        .font(.caption.weight(.medium))
                    Text("Offline")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Label(captureBoundaryLabel, systemImage: captureBoundarySymbol)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .help("Visible content can appear in screen recordings and accessibility tools. The legacy window sharing preference is not a privacy boundary.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(.bar)
            }
        } detail: {
            detail.overlay {
                if [.overview, .historicalReceipts, .graphBytes, .primeGit].contains(selection) {
                    ProvenanceWatermark().allowsHitTesting(false).accessibilityHidden(true)
                }
            }
        }
        .tint(accent)
    }

    private var captureBoundaryLabel: String {
        "Screen capture possible"
    }

    private var captureBoundarySymbol: String {
        "eye"
    }

    @ViewBuilder
    private var detail: some View {
        switch selection {
        case .agents:
            ErgenticsAgentsView(model: ErgenticsAgentsWorkspace.model)
        case .workspace:
            workspaceHome
        case .virtualMachines:
            VStack(spacing: 0) {
                if lab.busy || lab.quarantined {
                    Label(lab.quarantined
                          ? "The hypervisor lab needs a relaunch before another guest can start."
                          : "Wait for the hypervisor lab run to finish before starting a VM.",
                          systemImage: "pause.circle")
                        .font(.callout).foregroundStyle(.orange).padding()
                }
                VMWorkspaceView(model: virtualMachines, admitted: model.admitted)
            }
        case .gitWorkspace:
            GitWorkspaceView(model: gitWorkspace, admitted: model.admitted)
                .padding(24)
        case .prime:
            PrimeComputeView(model: PrimeComputeModel.shared)
        case .primeGit:

            PrimeGitView(
                presentation: primeGit.presentation,
                importState: primeGit.importState,
                admitted: model.admitted
            ) { proposal in
                primeGit.handle(
                    proposal,
                    admission: model.readOnlyImportAdmission
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .deltaPU:
            deltaPUView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        default:
            standardDetail
        }
    }

    private var standardDetail: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("LOCAL / OFFLINE / DEVELOPMENT")
                            .font(.caption)
                            .tracking(2)
                            .foregroundStyle(accent)
                        Text(selection == .overview ? "Ergentics Prime" : selection.title)
                            .font(.largeTitle.weight(.semibold))
                    }
                    Spacer()
                    Image(systemName: selection.symbol)
                        .font(.largeTitle)
                        .foregroundStyle(accent)
                        .accessibilityHidden(true)
                }
                switch selection {
                case .overview:
                    identityPanel
                    hypervisorLabView
                    historyPanel
                case .hypervisorLab:
                    hypervisorLabView
                    vmPanel
                case .historicalReceipts:
                    historyPanel
                    receiptsPanel
                case .graphBytes:
                    graphPanel
                case .vmAndRepository:
                    vmPanel
                    repositoryPanel
                case .agents, .workspace, .prime, .virtualMachines, .gitWorkspace, .primeGit, .deltaPU:
                    EmptyView()
                }
                if selection != .hypervisorLab {
                    Text("Viewer identity ≠ historical producer identity. Presentation does not transfer authority.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(28)
            .frame(maxWidth: 1180, alignment: .leading)
        }
        .background(.background)
    }

    private var workspaceHome: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your workspace").font(.largeTitle.bold())
                    Text("Code, compute, and Prime in one place.")
                        .font(.title3).foregroundStyle(.secondary)
                    if let snapshot = gitWorkspace.snapshot {
                        Label(snapshot.root.lastPathComponent, systemImage: "folder")
                            .font(.headline)
                        Text(snapshot.root.path).font(.caption).foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    } else {
                        Text("Start by opening a local repository. Choose compute and inspect Prime from the same app.")
                            .foregroundStyle(.secondary)
                    }
                }
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Code", systemImage: "arrow.triangle.branch").font(.title2.bold())
                        if let snapshot = gitWorkspace.snapshot {
                            Text("\(snapshot.branch) · \(snapshot.changes.count) changed files")
                        } else {
                            Text("Review files, stage changes, and make local commits.")
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Button(gitWorkspace.snapshot == nil ? "Open repository…" : "Change repository…") {
                                gitWorkspace.chooseRepository()
                            }.disabled(!model.admitted || gitWorkspace.busy)
                                .accessibilityIdentifier("workspace.open-repository")
                            Button("Open Git workspace") { selection = .gitWorkspace }
                        }
                        if let error = gitWorkspace.error { Text(error).foregroundStyle(.red) }
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(12)
                }
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Compute", systemImage: "desktopcomputer").font(.title2.bold())
                        if let vm = virtualMachines.selectedWorkspace {
                            Text("\(vm.name) · \(virtualMachines.phase.rawValue)")
                        } else {
                            Text("Manage your ARM64 Linux VMs here. Prime’s model and compute services are on the Prime page.")
                                .foregroundStyle(.secondary)
                        }
                        Button("Open virtual machines") { selection = .virtualMachines }
                            .accessibilityIdentifier("workspace.open-vms")
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(12)
                }
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Prime", systemImage: "sparkles").font(.title2.bold())
                        Text(primeCompute.status)
                        if let report = primeCompute.report {
                            Text(report.device).foregroundStyle(.secondary)
                        }
                        Text("Run the learned Prime domain model and geometry GPU service.")
                            .foregroundStyle(.secondary)
                        Button("Open Prime") { selection = .prime }
                            .accessibilityIdentifier("workspace.open-prime")
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(12)
                }
                Text("Repository and VM selections are independent today. This home reflects their live state; it does not mount a repository into a guest or start work automatically.")
                    .font(.caption).foregroundStyle(.secondary)
            }.padding(28).frame(maxWidth: 1000, alignment: .leading)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .accessibilityIdentifier("workspace.home")
    }

    private var hypervisorLabView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if virtualMachines.isActive {
                Label("Finish the VM operation, or stop or suspend the VM, before starting a hypervisor lab guest.", systemImage: "pause.circle")
                    .foregroundStyle(.orange)
            }
            HypervisorLabView(lab: lab, admitted: model.admitted && (!virtualMachines.isActive || lab.busy))
        }
    }

    @ViewBuilder
    private var deltaPUView: some View {
        #if DEBUG
        DeltaPUDemoView(model: deltaPU, readiness: deltaPUReadiness)
        #else
        DeltaPUDemoView(model: deltaPU)
        #endif
    }

    private var identityPanel: some View {
        panel("APPLICATION IDENTITY") {
            Text("com.ergentics.provenance")
                .font(.system(.title3, design: .monospaced))
            Text(model.signingStatus)
                .foregroundStyle(model.admitted ? accent : .orange)
            Text("Configured developer team: \(model.team)")
                .font(.caption)
            Text("App Sandbox with explicit user-selected access. Historical receipts are read only; the Git workspace writes only on Stage, Unstage or Commit. VM disks and journals stay in private app storage. No network entitlement.")
                .foregroundStyle(.secondary)
        }
    }

    private var historyPanel: some View {
        panel("HISTORICAL RESULT") {
            HStack {
                Text(model.snapshot == nil ? "No historical result admitted" : "Historical STATIC PASS · bytes verified")
                    .font(.title3)
                    .foregroundStyle(model.snapshot == nil ? .secondary : accent)
                Spacer()
                if model.busy { ProgressView().controlSize(.small) }
                Button("Open retained receipts…") {
                    Task { await model.selectHistory() }
                }
                .disabled(!model.admitted || model.busy)
            }
            Text(model.selectedHistory)
                .font(.caption)
                .privacySensitive()
            Text("Select the existing native-static-177403f-r1 folder. It is read in place; no copy, rewrite, migration, retry or new computation occurs.")
                .foregroundStyle(.secondary)
            if let snapshot = model.snapshot {
                Divider()
                Text("12 / 12 pinned artifacts · all manifest hashes and sizes match · three retained graphs are byte-identical")
                Text("Original producer: com.ergentics.PrivateCompute")
                Text("Historical interval: \(snapshot.elapsed)")
                    .font(.system(.body, design: .monospaced))
                Text("Raw ticks through historical leaf persistence; not this viewer's duration, CPU time or energy. Energy: not measured (ergs).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                commitment("Recorded Merkle root", snapshot.merkleRoot)
                commitment("Recorded semantic root", snapshot.semanticRoot)
                Text("Commitments are read from pinned historical bytes—not reconstructed or re-executed here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if model.error != nil {
                Label("The selected historical result was rejected. Details remain in the internal diagnostic boundary.",
                      systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
            }
        }
    }

    private var vmPanel: some View {
        panel("HYPERVISOR FRAMEWORK · CAPABILITY QUERIES ONLY") {
            if let capability = model.hypervisor {
                Text("Host support: " + (capability.support_error == 0 ? String(capability.host_supported) : "unobserved"))
                Text("Capability calls entered: \(capability.queries_entered)")
                Text("vCPU limit: " + (capability.queries_entered == 2 && capability.vcpu_status == 0 ? String(capability.max_vcpus) : "unobserved"))
                Text("Maximum IPA width: " + (capability.queries_entered == 2 && capability.ipa_status == 0 ? "\(capability.max_ipa_bits) bits" : "unobserved"))
            } else {
                Text("No Hypervisor capability query has been admitted.")
            }
            Text("These are support and limit queries, not execution counters. The Hypervisor lab separately records each fixed guest run.")
                .font(.system(.caption, design: .monospaced))
                .lineSpacing(5)
            Text("A vCPU limit is not a created CPU; IPA width is not allocated RAM. The fixed guest has no OS disk, network adapter, or installer.")
                .foregroundStyle(.secondary)
            Text("Apple Private Cloud Compute is separate. Account entitlements are not proof that this app is running a VM or using PCC.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var repositoryPanel: some View {
        panel("LOCAL WORKSPACES") {
            Text("Open Virtual machines to create an offline Linux VM from a selected ARM64 installer. Open Git workspace to review changes, stage files, and make local commits in a selected repository.")
                .foregroundStyle(.secondary)
            HStack {
                Button("Virtual machines") { selection = .virtualMachines }
                Button("Git workspace") { selection = .gitWorkspace }
            }
            Text("Prime Git keeps its existing imported snapshots and proposal review.")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private var receiptsPanel: some View {
        panel("READ-ONLY SNAPSHOT INVENTORY") {
            if let snapshot = model.snapshot {
                ForEach(snapshot.entries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.name)
                            Spacer()
                            Text("\(entry.bytes) bytes")
                        }
                        Text(entry.sha256)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                }
                Text("Snapshot-time joins only. Descriptors, mode, and vnode identities were checked across capture; no ongoing watch or ancestry-wide continuity is claimed.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Choose the historical receipt folder first.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var graphPanel: some View {
        panel("EXACT RETAINED GRAPH · NO RECONSTRUCTION") {
            if let snapshot = model.snapshot {
                commitment("Graph SHA-256", snapshot.graphHash)
                Text(String(decoding: snapshot.graph, as: UTF8.self))
                    .font(.system(.caption, design: .monospaced))
                    .privacySensitive()
            } else {
                Text("No graph bytes have been admitted.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func commitment(_ label: String, _ hash: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(hash)
                .font(.system(.caption, design: .monospaced))
                .privacySensitive()
        }
    }

    private func panel<Content: View>(_ title: String,
                                      @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            Text(title)
                .font(.caption.weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(accent)
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.separator.opacity(0.55))
        }
    }
}
